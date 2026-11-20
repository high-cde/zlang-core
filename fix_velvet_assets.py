import subprocess
import urllib.request

velvet_conf = "/etc/nginx/sites-available/velvethub"
velvet_content = """server {
    listen 80;
    listen [::]:80;
    server_name velvet.x-zdos.it;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name velvet.x-zdos.it;

    ssl_certificate /etc/letsencrypt/live/velvet.x-zdos.it/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/velvet.x-zdos.it/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    root /var/www/velvethub/dist/public;
    index index.html;

    location = /lodge-card.html {
        alias /var/www/ourvelvet/lodge-card.html;
        default_type text/html;
    }

    location ^~ /assets/ {
        root /var/www/velvethub/dist/public;
        try_files $uri @ourvelvet_assets;
    }

    location @ourvelvet_assets {
        root /var/www/ourvelvet;
        try_files $uri =404;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
"""
with open(velvet_conf, "w", encoding="utf-8") as f:
    f.write(velvet_content)

subprocess.run(["nginx", "-t"], check=True)
subprocess.run(["systemctl", "reload", "nginx"], check=True)
print("OK_NGINX_RELOAD")

for u in [
    "https://velvet.x-zdos.it/",
    "https://velvet.x-zdos.it/assets/index-D6kGSsJk.js",
    "https://velvet.x-zdos.it/assets/index-JUYiyPB_.css",
    "https://velvet.x-zdos.it/lodge-card.html",
]:
    req = urllib.request.Request(u, method="HEAD")
    with urllib.request.urlopen(req, timeout=8) as r:
        print(f"OK {u} -> {r.status} ({r.headers.get('Content-Type')})")
