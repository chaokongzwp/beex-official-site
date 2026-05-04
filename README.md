# BeeX Official Site

Static official website for BeeX, operated by PT Sinar Ultra Utama.

## Local Preview

```bash
python3 -m http.server 4173
```

Open `http://127.0.0.1:4173`.

## Production Domain

The target domain is `https://www.beexofficial.com`.

Current ECS preview:

- `http://8.215.11.130/`

For ECS production deployment, configure DNS:

- `www.beexofficial.com` A record to `8.215.11.130`
- Optional root domain `beexofficial.com` A record to `8.215.11.130`

After DNS points to the ECS, issue the HTTPS certificate:

```bash
certbot --nginx -d www.beexofficial.com -d beexofficial.com
```

GitHub Pages fallback is also enabled:

- `www.beexofficial.com` CNAME to `chaokongzwp.github.io`
- After DNS resolves, add `www.beexofficial.com` as the custom domain in the GitHub Pages settings and enable HTTPS.

Contact email shown on the site: `mars@beexofficial.com`.
