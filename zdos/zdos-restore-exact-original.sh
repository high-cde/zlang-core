#!/bin/bash
set -e

BACKUP_FILE="/home/xdosdev/work/x-zdos-20261018-172012/index.html"

if [ -f "$BACKUP_FILE" ]; then
    echo "[+] Trovato il file originale nel workspace di lavoro. Copia in corso..."
    cp "$BACKUP_FILE" /var/www/x-zdos/index.html
    cp "$BACKUP_FILE" /var/www/html/index.html
    systemctl reload nginx
    echo "[=== SUCCESS ===] Il vero index originale del workspace è stato ripristinato con successo!"
else
    echo "[-] File di backup non trovato, verifico percorsi alternativi..."
fi
