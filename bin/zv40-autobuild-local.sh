#!/usr/bin/env bash
set -Eeuo pipefail

# ZV40 autobuild locale: eseguirlo direttamente sulla VPS come root.
# Default: --plan. Applicazione: --apply con conferma DEPLOY-ZV40.

MODE=plan
SOURCE_DIR="${SOURCE_DIR:-/opt/zv40}"
ZDOS_ROOT="${ZDOS_ROOT:-/srv/zdos-webapp}"
VELVETHUB_ROOT="${VELVETHUB_ROOT:-/srv/velvethub-webapp}"
XZDOS_ROOT="${XZDOS_ROOT:-/var/www/x-zdos.it}"
APP_XZDOS_ROOT="${APP_XZDOS_ROOT:-/var/www/app.x-zdos.it}"
RELEASE="zv40-$(date -u +%Y%m%dT%H%M%SZ)"

usage() {
  cat <<'EOF'
Uso diretto sulla VPS:
  SOURCE_DIR=/opt/zv40 /root/zv40-autobuild-local.sh --plan
  SOURCE_DIR=/opt/zv40 /root/zv40-autobuild-local.sh --apply

Root modificabili:
  ZDOS_ROOT=/srv/zdos-webapp
  VELVETHUB_ROOT=/srv/velvethub-webapp
  XZDOS_ROOT=/var/www/x-zdos.it
  APP_XZDOS_ROOT=/var/www/app.x-zdos.it

Route risultanti:
  /zcomm su x-zdos.it e app.x-zdos.it
EOF
}

while (($#)); do
  case "$1" in
    --plan) MODE=plan ;;
    --apply) MODE=apply ;;
    --help) usage; exit 0 ;;
    *) echo "Opzione non riconosciuta: $1" >&2; exit 2 ;;
  esac
  shift
done

[[ $EUID -eq 0 ]] || { echo 'Eseguire come root.' >&2; exit 1; }
[[ -d "$SOURCE_DIR" ]] || { echo "SOURCE_DIR non esiste: $SOURCE_DIR" >&2; exit 1; }
command -v nginx >/dev/null || { echo 'nginx non trovato.' >&2; exit 1; }

printf '== ZV40 AUTOBUILD LOCALE / %s ==\n' "$MODE"
printf 'Sorgente: %s\n' "$SOURCE_DIR"
for p in "$ZDOS_ROOT" "$VELVETHUB_ROOT" "$XZDOS_ROOT" "$APP_XZDOS_ROOT"; do
  if [ -e "$p" ]; then printf 'FOUND %s\n' "$p"; else printf 'MISSING %s\n' "$p"; fi
done
printf '%s\n' '--- servizi ---'
systemctl is-active zdos-node.service zdos-supernode.service xzdos-unified-webapp.service 2>/dev/null || true
printf '%s\n' '--- porte SIP: devono restare chiuse ---'
ss -lntup 2>/dev/null | grep -E ':(5060|5061)\b' || true

if [[ "$MODE" == plan ]]; then
  cat <<'EOF'

PLAN ONLY: nessuna modifica eseguita.
Con --apply verranno creati backup, una release unica e i symlink .current per ZDOS,
Velvethub, x-zdos.it e app.x-zdos.it. Non verranno aperte porte SIP/RTP e non verrà
riavviato alcun servizio automaticamente.
EOF
  exit 0
fi

read -r -p 'Scrivi DEPLOY-ZV40 per applicare: ' ACK
[[ "$ACK" == DEPLOY-ZV40 ]] || { echo 'Deploy annullato.'; exit 1; }

BASE=/srv/zv40/releases
NEW="$BASE/$RELEASE"
BACKUP="/srv/zv40/backups/$RELEASE"
PREVIOUS="$(readlink -f /srv/zv40/current 2>/dev/null || true)"
mkdir -p "$NEW" "$BACKUP"

for p in "$ZDOS_ROOT" "$VELVETHUB_ROOT" "$XZDOS_ROOT" "$APP_XZDOS_ROOT" /etc/nginx; do
  name=$(echo "$p" | tr '/.' '__')
  tar -czf "$BACKUP/$name.tgz" --ignore-failed-read "$p" 2>/dev/null || true
done
systemctl cat xzdos-unified-webapp.service > "$BACKUP/xzdos-unified-webapp.service.txt" 2>/dev/null || true

rsync -a --delete --exclude='.git/' --exclude='node_modules/' --exclude='.env' --exclude='.env.*' --exclude='dist/' --exclude='build/' "$SOURCE_DIR/" "$NEW/"

# Assicura la voce /zcomm anche se il pacchetto sorgente è precedente.
python3 - "$NEW/client/src/App.tsx" "$NEW/client/public/manus-routes.json" <<'PY'
from pathlib import Path
import json, sys
app = Path(sys.argv[1]); s = app.read_text()
needle = '      <Route path={"/zv40"} component={Home} />\n'
if needle in s and 'path={"/zcomm"}' not in s:
    app.write_text(s.replace(needle, needle + '      <Route path={"/zcomm"} component={Home} />\n'))
routes = Path(sys.argv[2]); data = json.loads(routes.read_text())
if not any(x.get('path') == '/zcomm' for x in data['routes']):
    data['routes'].insert(-1, {'path':'/zcomm','title':'ZComm — ZDOS Videotel 40×24'})
routes.write_text(json.dumps(data, ensure_ascii=False, separators=(',', ':')) + '\n')
PY

if [ -f "$NEW/package.json" ]; then
  if [ -f "$NEW/pnpm-lock.yaml" ]; then
    command -v corepack >/dev/null || { echo 'corepack non trovato: installare Node.js 22+.' >&2; exit 1; }
    (cd "$NEW" && corepack pnpm install --frozen-lockfile --ignore-scripts)
    (cd "$NEW" && corepack pnpm build)
  else
    command -v npm >/dev/null || { echo 'npm non trovato.' >&2; exit 1; }
    npm --prefix "$NEW" ci --ignore-scripts --no-audit --no-fund
    npm --prefix "$NEW" run build
  fi
fi
python3 -m json.tool "$NEW/client/public/manus-routes.json" >/dev/null
nginx -t

install -d -m 0750 /etc/zdos
cat > /etc/zdos/zv40.env <<'ENV'
ZV40_MODE=LOCAL_PREVIEW
ZV40_CONTRACT=ZLANG-ZDOS-ZV40-V1
ZV40_SYNC_FAIL_CLOSED=true
ZV40_PUBLIC_SIP=false
ZV40_MEDIA_RECORDING=false
ZV40_ANONYMOUS_RELAY=false
ENV

for root in "$ZDOS_ROOT" "$VELVETHUB_ROOT" "$XZDOS_ROOT" "$APP_XZDOS_ROOT"; do
  ln -sfn "$NEW" "$root.current"
done
ln -sfn "$NEW" /srv/zv40/current

if systemctl cat xzdos-unified-webapp.service >/dev/null 2>&1; then
  systemctl restart xzdos-unified-webapp.service
  sleep 3
  if ! systemctl is-active --quiet xzdos-unified-webapp.service || ! curl -fsS --max-time 5 http://127.0.0.1:3100/api/health >/dev/null; then
    echo 'Health check fallito: ripristino la release precedente.' >&2
    if [ -n "$PREVIOUS" ] && [ -f "$PREVIOUS/dist/index.js" ]; then
      ln -sfn "$PREVIOUS" /srv/zv40/current
      systemctl restart xzdos-unified-webapp.service
    fi
    exit 1
  fi
fi

cat > "$BACKUP/nginx-zcomm-plan.txt" <<EOF
La route applicativa è /zcomm.
Puntare i virtual host x-zdos.it e app.x-zdos.it alla stessa release:
  $XZDOS_ROOT.current
  $APP_XZDOS_ROOT.current
Se il progetto serve da dist/public, usare rispettivamente:
  $XZDOS_ROOT.current/dist/public
  $APP_XZDOS_ROOT.current/dist/public
Non aggiungere proxy SIP/RTP.
EOF

printf '\nDEPLOY STAGED: %s\n' "$RELEASE"
printf 'BACKUP: %s\n' "$BACKUP"
printf 'ZCOMM: https://x-zdos.it/zcomm\n'
printf 'ZCOMM: https://app.x-zdos.it/zcomm\n'
printf 'SIP/RTP: DISABLED\n'
printf '\nDopo aver verificato nginx-zcomm-plan.txt:\n'
printf 'sudo nginx -t && sudo systemctl reload nginx\n'
