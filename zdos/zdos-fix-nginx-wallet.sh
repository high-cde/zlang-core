#!/bin/bash
set -e

echo "=== [ZDOS] Configurazione Reverse Proxy Nginx e Frontend Wallet ==="

# 1. Configurazione di Nginx per inoltrare /faucet/ e /api/ verso le porte interne
cat << 'NGINX_EOF' > /etc/nginx/sites-available/x-zdos
server {
    listen 80;
    server_name x-zdos.it www.x-zdos.it;

    root /var/www/x-zdos;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    # Proxy per il backend Node.js (Porta 8081)
    location /api/ {
        proxy_pass http://127.0.0.1:8081/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Proxy per il faucet autonomo Python (Porta 8082)
    location /faucet/ {
        proxy_pass http://127.0.0.1:8082/faucet/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    location /user/ {
        proxy_pass http://127.0.0.1:8082/user/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
NGINX_EOF

# Abilitiamo e testiamo Nginx
ln -sf /etc/nginx/sites-available/x-zdos /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx

echo "=== [SUCCESS] Nginx configurato con successo come reverse proxy per Faucet e API! ==="
