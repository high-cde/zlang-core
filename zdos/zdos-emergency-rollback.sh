#!/bin/bash
set -e

echo "=== [ZDOS] Avvio ripristino di emergenza e pulizia totale ==="

WEB_DIR="/var/www/x-zdos"
HTML_DIR="/var/www/html"

# Rimuoviamo eventuali file temporanei o cartelle corrotte
rm -rf /root/zdos/zbag-wallet
rm -f "$WEB_DIR/wallet.html"
rm -f "$HTML_DIR/wallet.html"

# Ripristiniamo una pagina index pulita e sicura
cat << 'SAFE_INDEX' > "$WEB_DIR/index.html"
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ZDOS // System Recovery</title>
  <style>
    body { background: #07090c; color: #00ffcc; font-family: 'Courier New', Courier, monospace; margin: 0; padding: 40px; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
    .card { background: #0f1620; border: 1px solid #1e293b; border-radius: 8px; padding: 30px; max-width: 450px; text-align: center; }
    h1 { color: #fff; font-size: 1.2rem; margin-bottom: 10px; }
    p { color: #94a3b8; font-size: 0.85rem; }
  </style>
</head>
<body>
  <div class="card">
    <h1>⚡ ZDOS // SISTEMA RIPRISTINATO</h1>
    <p>Il server è tornato in uno stato pulito e stabile. Pronto per nuove disposizioni.</p>
  </div>
</body>
</html>
SAFE_INDEX

cp "$WEB_DIR/index.html" "$HTML_DIR/index.html"

# Ricarichiamo Nginx per pulire la cache dei proxy
systemctl reload nginx

echo "=== [SUCCESS] Rollback completato con successo. Sito pulito e stabile! ==="
