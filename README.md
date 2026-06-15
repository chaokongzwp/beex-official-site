# BeeX Official Site

Static official website for BeeX, an Indonesia-focused affiliate commerce app.

## Local Preview

```bash
python3 -m http.server 4173
```

Open `http://127.0.0.1:4173`.

## OSS/CDN Deploy

The official site is a static website and can be deployed to Alibaba Cloud OSS
behind CDN.

```bash
ALIYUN_PROFILE=beex-ram \
OSS_BUCKET=beex-official-site \
OSS_ENDPOINT=oss-ap-southeast-5.aliyuncs.com \
CDN_DOMAIN=www.beexofficial.com \
bash scripts/deploy-oss-cdn.sh
```

The script uploads static files, configures OSS website index fallback, and
refreshes the CDN directory.

## Production Domain

The target domain is `https://www.beexofficial.com`.

Current production delivery:

- OSS bucket: `beex-official-site`
- OSS region: `oss-ap-southeast-5`
- CDN domain: `www.beexofficial.com`
- CDN CNAME: `www.beexofficial.com.queniuaa.com`
- DNS: `www.beexofficial.com` CNAME to the CDN CNAME
- HTTPS: enabled on Alibaba Cloud CDN

The OSS bucket is private. CDN private OSS origin authentication is configured
in Alibaba Cloud CDN and must not be stored in this repository. This deploy
script only uploads static assets and refreshes CDN cache.

The root domain `beexofficial.com` is intentionally kept separate because it
also hosts email-related DNS records.

Contact email shown on the site: `support@beexofficial.com`.
