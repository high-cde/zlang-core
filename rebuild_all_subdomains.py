import os
import subprocess
import urllib.request

# 1. Aggiorna velvethub per servire anche la home statica di VelvetHub + lodge-card.html
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

    location = /lodge-card.html {
        alias /var/www/ourvelvet/lodge-card.html;
        default_type text/html;
    }

    location /assets/ {
        alias /var/www/ourvelvet/assets/;
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
        root /var/www/velvethub;
        try_files /dist/public$uri /dist/public/index.html $uri $uri/ /index.html =404;
    }
}
"""
with open(velvet_conf, "w", encoding="utf-8") as f:
    f.write(velvet_content)

# 2. Ricostruisce tutti gli altri sottodomini: swap, quest, zdesk, app
subdomains_conf = "/etc/nginx/sites-available/zdos-subdomains.conf"
subdomains_content = """# SWAP.X-ZDOS.IT
server {
    listen 80;
    listen [::]:80;
    server_name swap.x-zdos.it;
    return 301 https://$host$request_uri;
}
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name swap.x-zdos.it;

    ssl_certificate /etc/letsencrypt/live/swap.x-zdos.it/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/swap.x-zdos.it/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    root /var/www/zswap;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html =404;
    }
}

# QUEST.X-ZDOS.IT (attivo su 127.0.0.1:3200)
server {
    listen 80;
    listen [::]:80;
    server_name quest.x-zdos.it;
    return 301 https://$host$request_uri;
}
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name quest.x-zdos.it;

    ssl_certificate /etc/letsencrypt/live/quest.x-zdos.it/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/quest.x-zdos.it/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://127.0.0.1:3200;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# ZDESK.X-ZDOS.IT (attivo su 127.0.0.1:8787)
server {
    listen 80;
    listen [::]:80;
    server_name zdesk.x-zdos.it;
    return 301 https://$host$request_uri;
}
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name zdesk.x-zdos.it;

    ssl_certificate /etc/letsencrypt/live/zdesk.x-zdos.it/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/zdesk.x-zdos.it/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://127.0.0.1:8787;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# APP.X-ZDOS.IT
server {
    listen 80;
    listen [::]:80;
    server_name app.x-zdos.it;
    return 301 https://$host$request_uri;
}
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name app.x-zdos.it;

    ssl_certificate /etc/letsencrypt/live/app.x-zdos.it/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app.x-zdos.it/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    root /var/www/app.x-zdos.it;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html =404;
    }
}
"""
with open(subdomains_conf, "w", encoding="utf-8") as f:
    f.write(subdomains_content)

# 3. Attiva i symlink in sites-enabled
enabled = "/etc/nginx/sites-enabled"
for name, target in [
    ("velvethub", velvet_conf),
    ("x-zdos-unified", "/etc/nginx/sites-available/x-zdos-unified"),
    ("zdos-subdomains.conf", subdomains_conf),
]:
    link = os.path.join(enabled, name)
    if os.path.lexists(link):
        os.unlink(link)
    os.symlink(target, link)

subprocess.run(["nginx", "-t"], check=True)
subprocess.run(["systemctl", "reload", "nginx"], check=True)
print("✅ Tutti i sottodomini configurati e ricaricati!")

urls = [
    "https://x-zdos.it/",
    "https://velvet.x-zdos.it/",
    "https://velvet.x-zdos.it/lodge-card.html",
    "https://swap.x-zdos.it/",
    "https://quest.x-zdos.it/",
    "https://zdesk.x-zdos.it/",
    "https://app.x-zdos.it/",
]
for u in urls:
    try:
        req = urllib.request.Request(u, method="GET")
        with urllib.request.urlopen(req, timeout=8) as r:
            print(f"✅ {u} -> HTTP {r.status}")
    except urllib.error.HTTPError as he:
        print(f"ℹ️ {u} -> HTTP {he.code}")
    except Exception as e:
        print(f"⚠️ {u} -> {e}")
