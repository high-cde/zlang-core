#!/bin/bash
echo "=== [ZDOS-CORE] Scansione globale per: Velvet ==="

# 1. Ricerca nel File System locale (escludendo directory di sistema pesanti)
echo -e "\n--- 1. Ricerca file locali (Progetti, Config, Daemon) ---"
grep -rnwi \
  --exclude-dir={proc,sys,dev,boot,lib,lib64,run} \
  --exclude="*.log" \
  -e "Velvet" / 2>/dev/null | head -n 40

# 2. Controllo processi attivi in PM2
echo -e "\n--- 2. Processi PM2 correlati ---"
pm2 jlist | jq -r '.[] | select(.name | test("velvet|red", "i")) | "Nome: \(.name) | Stato: \(.pm2_env.status) | Script: \(.pm2_env.pm_exec_path)"'

# 3. Ricerca nei repository GitHub locali o cloni (se presenti)
echo -e "\n--- 3. Ricerca nei repository Git locali ---"
for dir in $(find / -name ".git" -type d 2>/dev/null | grep -v "/proc/" | sed 's/\/.git$//'); do
    if git -C "$dir" remote -v 2>/dev/null | grep -qi "VelvetHub\|RedVelvet"; then
        echo "[Trovato Repo Git]: $dir"
        git -C "$dir" remote -v
    fi
done

# 4. Ricerca remota su GitHub (richiede GitHub CLI 'gh' autenticato)
if command -v gh &> /dev/null; then
    echo -e "\n--- 4. Ricerca nei repository remoti GitHub (high-cde) ---"
    gh repo list high-cde --limit 30 | grep -i "velvet"
else
    echo -e "\n--- 4. GitHub CLI (gh) non installato, salto la query remota ---"
fi

echo -e "\n=== Scansione completata ==="
