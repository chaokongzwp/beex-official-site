#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ALIYUN_PROFILE="${ALIYUN_PROFILE:-beex-ram}"
OSS_ENDPOINT="${OSS_ENDPOINT:-oss-ap-southeast-5.aliyuncs.com}"
OSS_BUCKET="${OSS_BUCKET:-beex-official-site}"
CDN_DOMAIN="${CDN_DOMAIN:-www.beexofficial.com}"
CDN_SCHEME="${CDN_SCHEME:-https}"
CDN_REQUIRED="${CDN_REQUIRED:-false}"

if ! command -v aliyun >/dev/null 2>&1; then
  echo "aliyun CLI is required." >&2
  exit 2
fi

if ! command -v ossutil >/dev/null 2>&1; then
  echo "ossutil is required." >&2
  exit 2
fi

WEBSITE_CONFIG="$(mktemp)"
trap 'rm -f "$WEBSITE_CONFIG"' EXIT

cat > "$WEBSITE_CONFIG" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<WebsiteConfiguration>
  <IndexDocument>
    <Suffix>index.html</Suffix>
  </IndexDocument>
  <ErrorDocument>
    <Key>index.html</Key>
  </ErrorDocument>
</WebsiteConfiguration>
XML

echo "Ensuring OSS bucket: oss://${OSS_BUCKET}"
aliyun --profile "$ALIYUN_PROFILE" oss mb "oss://${OSS_BUCKET}" \
  -e "$OSS_ENDPOINT" \
  --acl=private >/dev/null || true

aliyun --profile "$ALIYUN_PROFILE" oss website --method put "oss://${OSS_BUCKET}" "$WEBSITE_CONFIG" \
  -e "$OSS_ENDPOINT" >/dev/null

echo "Uploading static files to oss://${OSS_BUCKET}"
find . -maxdepth 1 -type f \
  ! -name '.DS_Store' \
  ! -name '*.pdf' \
  -print0 | while IFS= read -r -d '' file; do
    relative_path="${file#./}"
    aliyun --profile "$ALIYUN_PROFILE" oss cp "$file" "oss://${OSS_BUCKET}/${relative_path}" \
      -f -e "$OSS_ENDPOINT" \
      --meta='Cache-Control:no-cache'
  done

for dir in assets .well-known; do
  if [[ -d "$dir" ]]; then
    echo "Uploading ${dir}/"
    aliyun --profile "$ALIYUN_PROFILE" oss cp "$dir" "oss://${OSS_BUCKET}/${dir}" \
      -r -f -e "$OSS_ENDPOINT" \
      --meta='Cache-Control:public,max-age=31536000'
  fi
done

echo "Refreshing CDN: ${CDN_SCHEME}://${CDN_DOMAIN}/"
set +e
aliyun --profile "$ALIYUN_PROFILE" cdn RefreshObjectCaches \
  --ObjectPath "${CDN_SCHEME}://${CDN_DOMAIN}/" \
  --ObjectType Directory >/dev/null
refresh_status=$?
set -e

if [[ "$refresh_status" -ne 0 ]]; then
  if [[ "$CDN_REQUIRED" == "true" ]]; then
    echo "CDN refresh failed." >&2
    exit 1
  fi
  echo "CDN refresh failed or domain is not ready yet; OSS upload completed." >&2
fi

echo "Deploy finished. OSS bucket: oss://${OSS_BUCKET}, CDN domain: ${CDN_DOMAIN}"
