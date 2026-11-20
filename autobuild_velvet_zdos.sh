#!/usr/bin/env bash
set -euo pipefail

echo "=== [1/5] Controllo stato VPS, Nginx e servizi ==="
sudo nginx -t && sudo systemctl reload nginx || true
pm2 status || true

echo "=== [2/5] Riavvio demoni esistenti (se presenti) ==="
for srv in velvet-daemon zxsolana-bot; do
  if pm2 describe "$srv" >/dev/null 2>&1; then
    pm2 restart "$srv"
  elif systemctl list-unit-files | grep -q "^${srv}\.service"; then
    sudo systemctl restart "$srv" || true
  fi
done
pm2 save || true

echo "=== [3/5] Pulizia link WhatsApp & payload Telegram in invite-gate.html ==="
TARGET_GATE=$(find /var/www /opt /root -maxdepth 4 -name "invite-gate.html" 2>/dev/null | head -n 1 || true)
if [[ -n "${TARGET_GATE}" && -f "${TARGET_GATE}" ]]; then
  cp -a "${TARGET_GATE}" "${TARGET_GATE}.bak.$(date +%Y%m%d_%H%M%S)"
  sed -i 's/fuori par/ · /g; s/out par/ · /g; s/#ourvelvet-generator/\/invite-gate.html/g' "${TARGET_GATE}"
  echo "Aggiornato: ${TARGET_GATE}"
else
  echo "Nota: invite-gate.html non trovato automaticamente, verifica il percorso web root."
fi

echo "=== [4/5] Creazione modulo Automazione Canale & Comunicazione ==="
mkdir -p /opt/zdos-velvet-autobridge
cat <<'NODE_EOF' > /opt/zdos-velvet-autobridge/channel_automator.js
const fs = require('fs');
const path = require('path');

const CONFIG_PATH = path.join(__dirname, 'config.json');
const QUEUE_PATH = path.join(__dirname, 'queue.json');

const defaultConfig = {
  botToken: process.env.TG_BOT_TOKEN || '',
  channelChatId: process.env.TG_CHANNEL_ID || '@RedVelvetHub',
  groupInviteUrl: process.env.TG_GROUP_INVITE || 'https://t.me/+SostituisciConLinkGruppoRedvelvetHub',
  portalUrl: 'https://velvet.x-zdos.it',
  gateUrl: 'https://velvet.x-zdos.it/invite-gate.html',
  shopUrl: 'https://velvet.x-zdos.it/shop.html',
  xzdosSwapUrl: 'https://swap.x-zdos.it/?ref=6C61wDacAtx3QHQYVw17fnm5GEaEAnc1XienNJKn2bsD',
  treasuryWallet: '6C61wDacAtx3QHQYVw17fnm5GEaEAnc1XienNJKn2bsD',
  dsnMint: '35w74RT77BPSYNpmzpvxmR9wu2ihpgzubKy4bkGHR3F4',
  ovMint: '2EN6Y1zM4yyt41gE2muzdJSAgRCAZiXqnmkgpbrspump',
  pollIntervalMs: 30000
};

if (!fs.existsSync(CONFIG_PATH)) {
  fs.writeFileSync(CONFIG_PATH, JSON.stringify(defaultConfig, null, 2));
}

if (!fs.existsSync(QUEUE_PATH)) {
  fs.writeFileSync(QUEUE_PATH, JSON.stringify([
    {
      id: 'welcome-reading-club-01',
      sent: false,
      text: [
        '🥀 OUR VELVET · SALOTTO DI LETTURA & ARCHIVIO 18+',
        '',
        'Racconti erotici a puntate, ebook (PDF/EPUB), scambi consensuali e drop 18+.',
        '🌐 Portale: https://velvet.x-zdos.it',
        '🗝️ ID Globale ($OV): https://velvet.x-zdos.it/invite-gate.html',
        '🛒 Shop 18+: https://velvet.x-zdos.it/shop.html',
        '⚡ xZDOS ($DSN): https://swap.x-zdos.it/?ref=6C61wDacAtx3QHQYVw17fnm5GEaEAnc1XienNJKn2bsD',
        '',
        'Build what you can prove. Solo 18+ · Consenso esplicito.'
      ].join('\n')
    }
  ], null, 2));
}

const cfg = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf8'));

function buildWhatsAppBridgeMessage({ code, alias, role, note }) {
  return [
    '🖤 Iniziazione Velvet City (18+)',
    `ID Globale: ${code || 'OV-XXXX-VELVET'}`,
    `Alias: ${alias || 'Membro'}`,
    `Ruolo: ${role || 'Sottomesso / Sub'}`,
    `Nota: ${note || 'Accesso verificato'}`,
    `Portale: ${cfg.portalUrl}`
  ].join('\n');
}

function buildTelegramStartPayload(code) {
  const cleanCode = encodeURIComponent((code || 'OV-XXXX-VELVET').trim());
  return `https://t.me/RedVelvetOfficial_bot?start=ov_${cleanCode}`;
}

async function sendTelegramMessage(chatId, text) {
  if (!cfg.botToken) {
    console.log('[DRY-RUN TG] Imposta TG_BOT_TOKEN in config.json o env per inviare su:', chatId);
    console.log(text);
    return false;
  }
  const res = await fetch(`https://api.telegram.org/bot${cfg.botToken}/sendMessage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      chat_id: chatId,
      text,
      disable_web_page_preview: false
    })
  });
  const data = await res.json();
  if (!data.ok) {
    throw new Error(`Telegram API error: ${JSON.stringify(data)}`);
  }
  return true;
}

async function processQueue() {
  const queue = JSON.parse(fs.readFileSync(QUEUE_PATH, 'utf8'));
  let changed = false;

  for (const item of queue) {
    if (!item.sent && item.text) {
      const ok = await sendTelegramMessage(cfg.channelChatId, item.text);
      if (ok) {
        item.sent = true;
        item.sentAt = new Date().toISOString();
        changed = true;
        console.log('[SENT]', item.id, '->', cfg.channelChatId);
      }
    }
  }

  if (changed) {
    fs.writeFileSync(QUEUE_PATH, JSON.stringify(queue, null, 2));
  }
}

console.log('[ZDOS-AUTOBRIDGE] Avviato. Canale:', cfg.channelChatId);
processQueue().catch(err => console.error('[QUEUE ERROR]', err.message));

setInterval(() => {
  processQueue().catch(err => console.error('[QUEUE ERROR]', err.message));
}, cfg.pollIntervalMs);

module.exports = {
  buildWhatsAppBridgeMessage,
  buildTelegramStartPayload,
  sendTelegramMessage
};
NODE_EOF

echo "=== [5/5] Avvio automazione su PM2 ==="
pm2 start /opt/zdos-velvet-autobridge/channel_automator.js --name zdos-channel-bridge --update-env
pm2 save
pm2 status
echo "=== AUTOBUILD COMPLETATO ==="
