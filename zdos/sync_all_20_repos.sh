#!/bin/bash
# ZDOS Mass Sync Engine per i 20 repository di high-cde

REPOS=(
    "x-zdos-webapp"
    "zBAG"
    "zclipper"
    "VelvetHub"
    "zdos-microcosm-beta"
    "ZDOS"
    "zdos-hybrid"
    "zdos-organism"
    "Zlang"
    "xzdos-vps-bundle"
    "xCLOUD-by-zdos"
    "ZDOS-lab-v1"
    "xzdos-unified-webapp"
    "NEXUS-X"
    "high-cde"
    "Z-GENESIS-HOST"
    "x-zdos-complete"
    "Z-GENESIS-OS"
    "System.zdos.znode"
    "zdos-core"
)

WORKSPACE="/root/zdos/github_workspace"
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

echo "🚀 [ZDOS MASS SYNC]: Inizio elaborazione di tutti i 20 repository di high-cde..."

for repo in "${REPOS[@]}"; do
    echo "--------------------------------------------------"
    echo "📦 Elaborazione repository: $repo"
    
    if [ ! -d "$repo/.git" ]; then
        echo "📥 Clonazione di $repo da https://github.com/high-cde/$repo.git ..."
        git clone "https://github.com/high-cde/$repo.git" || echo "⚠️ Impossibile clonare $repo (potrebbe essere privato o inesistente)."
    fi
    
    if [ -d "$repo/.git" ]; then
        cd "$repo"
        # Configura l'identità locale se necessario
        git config user.name "high-cde"
        git config user.email "kali@x-zdos.it"
        
        # Sincronizza lo stato corrente con l'ecosistema ZDOS
        git add .
        git commit -m "ZDOS Sovereign Sync: Aggiornamento automatico ecosistema globale" || echo "ℹ️ Nessuna modifica da committare per $repo."
        
        # Identifica il branch attivo (main o master)
        BRANCH=$(git branch --show-current)
        if [ -z "$BRANCH" ]; then
            BRANCH="main"
        fi
        
        echo "📤 Push in corso sul branch '$BRANCH' per $repo..."
        git push origin "$BRANCH" || git push origin master || echo "⚠️ Push fallito per $repo (verificare permessi Token/SSH)."
        cd "$WORKSPACE"
    fi
done

echo "✨ [MASS SYNC COMPLETATO]: Tutti i repository dell'ecosistema high-cde sono stati processati!"
