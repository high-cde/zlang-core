#!/bin/bash
set -e

BACKUP_FILE="/home/xdosdev/work/x-zdos-20261018-172012/index.html"

if [ -f "$BACKUP_FILE" ]; then
    cp "$BACKUP_FILE" /var/www/x-zdos/index.html
    cp "$BACKUP_FILE" /var/www/html/index.html
    systemctl reload nginx
    echo "[=== SUCCESS ===] Root principale ripristinata con l'index originale esatto!"
else
    echo "[-] File di backup non trovato."
fi
