#!/bin/bash
set -e

# Creiamo il codice HTML esatto del vecchio index nella sua forma più pulita
cat << 'INDEX_HTML' > /var/www/x-zdos/index.html
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ZDOS // Ecosystem</title>
  <style>
    body { background: #07090c; color: #f8fafc; font-family: 'Courier New', Courier, monospace; margin: 0; padding: 20px; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
    .card { background: #0f1620; border: 1px solid #1e293b; border-radius: 8px; padding: 30px; max-width: 600px; width: 100%; box-shadow: 0 4px 20px rgba(0,255,204,0.1); }
    h1 { color: #00ffcc; font-size: 1.4rem; margin-top: 0; }
    p { color: #94a3b8; font-size: 0.85rem; line-height: 1.5; }
    .links { display: flex; gap: 15px; margin-top: 20px; flex-wrap: wrap; }
    .link-btn { background: transparent; border: 1px solid #00ffcc; color: #00ffcc; padding: 8px 16px; border-radius: 4px; text-decoration: none; font-size: 0.85rem; font-family: monospace; transition: 0.2s; }
    .link-btn:hover { background: rgba(0,255,204,0.15); }
  </style>
</head>
<body>
  <div class="card">
    <h1>ZDOS e Zlang • repository correnti</h1>
    <p>Il workbench conserva il proprio stile e rimane disconnesso dai servizi di rete. Per distro Linux, target x86_64, toolchain Zlang e contratto ZLB2 consulta i progetti ufficiali.</p>
    <div class="links">
      <a href="https://github.com/high-cde" target="_blank" class="link-btn">ZDOS ↗</a>
      <a href="https://github.com/high-cde" target="_blank" class="link-btn">Zlang ↗</a>
    </div>
  </div>
</body>
</html>
INDEX_HTML

# Copiamo in modo identico su entrambe le directory di Nginx
cp /var/www/x-zdos/index.html /var/www/html/index.html

# Ricarichiamo Nginx per forzare l'aggiornamento
systemctl reload nginx
echo "=== Sincronizzazione completata con successo ==="
