#!/bin/bash
set -e

echo "=== [ZDOS] Avvio pulizia, scansione e riorganizzazione strutturale ==="

WEB_DIR="/var/www/x-zdos"
HTML_DIR="/var/www/html"

# 1. Pulizia di file orfani o doppi inutili
echo "[+] Rimozione file doppi o disallineati..."
rm -f "$WEB_DIR/update_wallet_dex.py"
rm -f "$WEB_DIR/wallet-miner.js"
rm -f "$HTML_DIR/update_wallet_dex.py"
rm -f "$HTML_DIR/wallet-miner.js"

# 2. Creazione della Home principale (index.html) pulita e coerente
cat << 'INDEX_EOF' > "$WEB_DIR/index.html"
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ZDOS // Ecosystem Hub</title>
  <style>
    body { background: #0b0e11; color: #eaecef; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 0; padding: 30px; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
    .hub-card { background: #181a20; border: 1px solid #2b313a; border-radius: 12px; padding: 30px; max-width: 450px; width: 100%; box-shadow: 0 4px 20px rgba(0,0,0,0.5); text-align: center; }
    h1 { color: #f0b90b; font-size: 1.5rem; margin-bottom: 10px; }
    p { color: #848e9c; font-size: 0.85rem; margin-bottom: 25px; }
    .nav-links { display: flex; flex-direction: column; gap: 12px; }
    .btn-portal { background: #2b313a; color: #fff; text-decoration: none; padding: 14px; border-radius: 8px; font-weight: bold; font-size: 0.95rem; border: 1px solid #363d4a; transition: 0.2s; display: block; }
    .btn-portal:hover { background: #f0b90b; color: #000; border-color: #f0b90b; }
  </style>
</head>
<body>
  <div class="hub-card">
    <h1>⚡ ZDOS ECOSYSTEM HUB</h1>
    <p>Seleziona il modulo operativo desiderato:</p>
    <div class="nav-links">
      <a href="/wallet.html" class="btn-portal">👛 Apri Binance Pro Vault &amp; Faucet</a>
      <a href="/swap.html" class="btn-portal">🥞 Apri CyberSwap DEX Router</a>
    </div>
  </div>
</body>
</html>
INDEX_EOF

# Sincronizziamo index.html anche in /var/www/html/
cp "$WEB_DIR/index.html" "$HTML_DIR/index.html"

# 3. Assicuriamoci che i permessi siano corretti per xdosdev e www-data
chown -R xdosdev:xdosdev "$WEB_DIR" || true
chown -R www-data:www-data "$WEB_DIR" || true

echo "=== [SUCCESS] Scansione, pulizia e riorganizzazione completate con successo! ==="
