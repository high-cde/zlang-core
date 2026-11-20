echo "🚀 [ZDOS GIT SYNC]: Avvio aggiornamento globale repository GitHub..."

# 1. Aggiornamento zBAG (Rainbow Fork)
if [ -d "/root/zdos/zBAG-runtime/.git" ]; then
    echo "📦 Sincronizzazione zBAG..."
    cd /root/zdos/zBAG-runtime
    git add .
    git commit -m "ZDOS: Aggiornamento automatico hyper-wallet e asset interni" || true
    git push origin main || echo "⚠️ Push zBAG saltato o richiede autenticazione manuale."
fi

# 2. Sincronizzazione xCLOUD / ZDOS Core
if [ -d "/var/www/x-zdos/.git" ]; then
    echo "📦 Sincronizzazione x-zdos..."
    cd /var/www/x-zdos
    git add .
    git commit -m "ZDOS Enterprise: Sincronizzazione backend SQLite e Multi-AI Gateway" || true
    git push origin main || echo "⚠️ Push x-zdos saltato o richiede autenticazione manuale."
fi

echo "✨ [GIT SYNC COMPLETATO]: Tutti i repository locali sono stati elaborati."
