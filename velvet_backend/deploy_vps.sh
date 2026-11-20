#!/bin/bash
# Deploy / update OurVelvet su VPS – dominio velvet.x-zdos.it
# Esegui come root o con sudo sulla VPS

set -e

APP_DIR="/opt/ourvelvet"
REPO_OR_LOCAL="$APP_DIR"
DOMAIN="velvet.x-zdos.it"

echo "=== OurVelvet Full Update ==="

# 1. Dipendenze sistema
apt-get update -qq
apt-get install -y -qq python3-pip python3-venv nginx certbot python3-certbot-nginx postgresql postgresql-contrib

# 2. Directory
mkdir -p "$APP_DIR"
cd "$APP_DIR"

# 3. Se non c'è già il codice, copia o git pull (qui assumiamo che il codice sia già in /opt/ourvelvet)
# git pull || true

# 4. Venv + requirements
python3 -m venv venv
source venv/bin/activate
pip install -q --upgrade pip
pip install -q -r requirements.txt

# 5. .env (crea se non esiste)
if [ ! -f .env ]; then
  cat > .env << EOF
BOT_TOKEN=INSERISCI_IL_TUO_BOT_TOKEN
DATABASE_URL=postgresql+asyncpg://velvet:velvetpass@localhost:5432/velvetdb
SECRET_KEY=$(openssl rand -hex 32)
PRIMARY_CURRENCY=OV
EOF
  echo "Creato .env – modifica BOT_TOKEN"
fi

# 6. Database
sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='velvet'" | grep -q 1 || \
  sudo -u postgres psql -c "CREATE USER velvet WITH PASSWORD 'velvetpass';"
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname='velvetdb'" | grep -q 1 || \
  sudo -u postgres psql -c "CREATE DATABASE velvetdb OWNER velvet;"

# 7. Migrazioni
alembic upgrade head

# 8. Systemd service
cat > /etc/systemd/system/ourvelvet.service << EOF
[Unit]
Description=OurVelvet FastAPI
After=network.target postgresql.service

[Service]
User=root
WorkingDirectory=$APP_DIR
Environment="PATH=$APP_DIR/venv/bin"
ExecStart=$APP_DIR/venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ourvelvet
systemctl restart ourvelvet

# 9. Nginx + SSL
cat > /etc/nginx/sites-available/ourvelvet << EOF
server {
    listen 80;
    server_name $DOMAIN;
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

ln -sf /etc/nginx/sites-available/ourvelvet /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# SSL (solo se il dominio punta già alla VPS)
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN || echo "Certbot saltato (configura manualmente se necessario)"

echo "=== OurVelvet aggiornato e online su https://$DOMAIN ==="
echo "Mini App: https://$DOMAIN/app"
echo "Imposta il Web App URL del bot su https://$DOMAIN/app"
