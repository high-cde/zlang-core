#!/bin/bash
TARGET_DIR="/var/www/x-zdos"

# Creiamo il file wallet definitivo pulito
cat << 'HTML' > /root/zdos/final_wallet.html
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ZDOS // Netkali Multi-Token Vault</title>
  <style>
    body { background: #0a0d10; color: #00ffcc; font-family: 'Courier New', Courier, monospace; margin: 0; padding: 20px; }
    .zdos-wallet-container { max-width: 1000px; margin: 0 auto; background: #0a0d10; border: 1px solid #00ffcc33; border-radius: 6px; padding: 20px; }
    .wallet-header-card { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #00ffcc22; padding-bottom: 15px; margin-bottom: 20px; flex-wrap: wrap; gap: 15px; }
    .terminal-prompt { color: #ff0055; font-weight: bold; }
    .wallet-title-area h2 { font-size: 1.2rem; margin: 0; color: #fff; }
    .wallet-subtitle { font-size: 0.8rem; color: #88a0c0; margin: 5px 0 0 0; }
    .wallet-auth-box input { background: #111820; border: 1px solid #00ffcc66; color: #fff; padding: 8px 12px; border-radius: 4px; font-family: monospace; outline: none; }
    .wallet-auth-box button { background: #00ffcc; color: #000; border: none; padding: 8px 15px; font-weight: bold; border-radius: 4px; cursor: pointer; transition: 0.2s; }
    .wallet-auth-box button:hover { background: #00b388; }
    .wallet-user-box { display: flex; align-items: center; gap: 15px; background: #111820; padding: 8px 15px; border-radius: 4px; border: 1px solid #00ffcc44; }
    .user-badge { color: #fff; }
    .status-live-dot { color: #00ff66; font-size: 0.85rem; animation: pulse 1.5s infinite; }
    @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.4; } 100% { opacity: 1; } }
    .tokens-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 15px; margin-bottom: 20px; }
    .token-card { background: #111820; border: 1px solid #223344; border-radius: 6px; padding: 15px; position: relative; transition: 0.2s; }
    .token-card:hover { border-color: #00ffcc88; }
    .token-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
    .token-symbol { font-weight: bold; font-size: 1.1rem; color: #fff; }
    .token-name { font-size: 0.75rem; color: #88a0c0; }
    .token-balance { font-size: 1.3rem; font-weight: bold; color: #00ffcc; margin-bottom: 12px; }
    .claim-token-btn { width: 100%; background: transparent; border: 1px solid #00ffcc55; color: #00ffcc; padding: 6px; border-radius: 3px; cursor: pointer; font-size: 0.8rem; font-family: monospace; transition: 0.2s; }
    .claim-token-btn:hover { background: #00ffcc22; }
    .wallet-terminal-log { background: #050709; border: 1px solid #222; border-radius: 4px; padding: 10px; font-size: 0.75rem; }
    .log-header { color: #556677; border-bottom: 1px solid #1a222a; padding-bottom: 5px; margin-bottom: 5px; }
    .log-content { color: #88a0c0; max-height: 80px; overflow-y: auto; }
  </style>
</head>
<body>
<div class="zdos-wallet-container">
  <div class="wallet-header-card">
    <div class="wallet-title-area">
      <h2><span class="terminal-prompt">&gt;</span> NETKALI // MULTI-TOKEN CUSTODIAL VAULT</h2>
      <p class="wallet-subtitle">Autonomous 5-Min Micro-Airdrop Engine: ACTIVE</p>
    </div>
    <div id="auth-section" class="wallet-auth-box">
      <input type="text" id="username-input" value="Kali" placeholder="Nickname..." autocomplete="off" />
      <button onclick="registerUser()">Connetti &amp; Attiva</button>
    </div>
    <div id="user-info-section" class="wallet-user-box" style="display: none;">
      <span class="user-badge">Operatore: <strong id="display-username"></strong></span>
      <span class="status-live-dot">● Airdrop Live (Ogni 5m)</span>
    </div>
  </div>
  <div class="tokens-grid" id="tokens-grid"></div>
  <div class="wallet-terminal-log">
    <div class="log-header"><span>SYSTEM_LOG // WALLET_DAEMON</span></div>
    <div class="log-content" id="log-output">[00:00:00] Vault multi-asset connesso al faucet autonomo.</div>
  </div>
</div>
<script>
  let currentUsername = localStorage.getItem("netkali_username") || "Kali";
  const TOKEN_METADATA = {
    "DSN": { name: "Netkali DSN", icon: "🌐" },
    "BTC": { name: "Bitcoin", icon: "⚡" },
    "ETH": { name: "Ethereum", icon: "💎" },
    "POL": { name: "Polygon", icon: "🟣" },
    "SOL": { name: "Solana", icon: "☀️" },
    "ADA": { name: "Cardano", icon: "🔵" },
    "XRP": { name: "Ripple", icon: "💧" },
    "AVAX": { name: "Avalanche", icon: "🔺" },
    "DOGE": { name: "Dogecoin", icon: "🐕" },
    "LTC": { name: "Litecoin", icon: "🥈" },
    "SHIB": { name: "Shiba Inu", icon: "🐶" },
    "ZEC": { name: "Zcash", icon: "🛡️" }
  };
  function logMessage(msg) {
    const logBox = document.getElementById("log-output");
    const timeStr = new Date().toTimeString().split(' ')[0];
    logBox.innerHTML += `<br>[${timeStr}] ${msg}`;
    logBox.scrollTop = logBox.scrollHeight;
  }
  async function registerUser() {
    const username = document.getElementById("username-input").value.trim() || "Kali";
    try {
      const response = await fetch(`/user/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username })
      });
      const data = await response.json();
      if (data.success) {
        currentUsername = username;
        localStorage.setItem("netkali_username", username);
        document.getElementById("auth-section").style.display = "none";
        document.getElementById("user-info-section").style.display = "flex";
        document.getElementById("display-username").innerText = username;
        logMessage(`Operatore '${username}' connesso. Sincronizzazione saldi...`);
        loadBalances();
        setInterval(loadBalances, 15000);
      } else { alert("Errore: " + data.error); }
    } catch (err) { logMessage(`Errore di connessione: ${err.message}`); }
  }
  async function loadBalances() {
    if (!currentUsername) return;
    try {
      const response = await fetch(`/user/balances?username=${encodeURIComponent(currentUsername)}`);
      const data = await response.json();
      if (data.success) { renderTokens(data.balances); }
    } catch (err) { console.error("Errore saldi", err); }
  }
  function renderTokens(balances) {
    const grid = document.getElementById("tokens-grid");
    grid.innerHTML = "";
    for (const [symbol, balance] of Object.entries(balances)) {
      const meta = TOKEN_METADATA[symbol] || { name: symbol, icon: "🪙" };
      const card = document.createElement("div");
      card.className = "token-card";
      card.innerHTML = `
        <div class="token-header">
          <span class="token-symbol">${meta.icon} ${symbol}</span>
          <span class="token-name">${meta.name}</span>
        </div>
        <div class="token-balance">${Number(balance).toFixed(symbol === 'BTC' || symbol === 'ETH' || symbol === 'ZEC' || symbol === 'LTC' ? 6 : 2)}</div>
        <button class="claim-token-btn" onclick="claimManual('${symbol}')">Claim Bonus +${symbol}</button>
      `;
      grid.appendChild(card);
    }
  }
  async function claimManual(token) {
    if (!currentUsername) return;
    try {
      const response = await fetch(`/faucet/claim`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username: currentUsername, token })
      });
      const data = await response.json();
      if (data.success) {
        logMessage(`Claim manuale riuscito: +${data.claimed_amount} ${token}`);
        loadBalances();
      } else { alert("Claim fallito: " + data.error); }
    } catch (err) { logMessage(`Errore claim ${token}: ${err.message}`); }
  }
  window.addEventListener("DOMContentLoaded", () => {
    document.getElementById("username-input").value = currentUsername;
    registerUser();
  });
</script>
</body>
</html>
HTML

# Sovrascriviamo ovunque
cp /root/zdos/final_wallet.html "$TARGET_DIR/wallet.html"
cp /root/zdos/final_wallet.html "/var/www/html/wallet.html"
if [ -d "$TARGET_DIR/web" ]; then
    cp /root/zdos/final_wallet.html "$TARGET_DIR/web/wallet.html"
fi

echo "Sovrascrittura completata con successo!"
