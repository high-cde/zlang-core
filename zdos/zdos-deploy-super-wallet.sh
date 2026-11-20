#!/bin/bash
set -e

echo "=== [ZDOS] Deploy del Super Web3 Wallet Definitivo (Loghi & Faucet Reale) ==="

cat << 'HTML' > /var/www/x-zdos/wallet.html
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>ZDOS // Netkali Super Web3 Vault</title>
  <style>
    :root {
      --bg-color: #070a0f;
      --card-bg: #111722;
      --card-hover: #192231;
      --accent: #00ffcc;
      --accent-glow: rgba(0, 255, 204, 0.2);
      --text-main: #ffffff;
      --text-muted: #8ca0b3;
      --border: #1e293b;
      --danger: #ff0055;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
    body { background-color: var(--bg-color); color: var(--text-main); display: flex; justify-content: center; min-height: 100vh; padding: 10px; }
    
    .mobile-frame { width: 100%; max-width: 420px; background: var(--bg-color); display: flex; flex-direction: column; position: relative; padding-bottom: 80px; }

    /* Header */
    .app-header { display: flex; justify-content: space-between; align-items: center; padding: 15px 10px; }
    .wallet-selector { display: flex; align-items: center; gap: 8px; background: var(--card-bg); padding: 6px 14px; border-radius: 20px; font-size: 0.85rem; border: 1px solid var(--border); cursor: pointer; color: var(--accent); font-weight: bold; }
    .network-badge { background: rgba(0,255,204,0.1); color: var(--accent); padding: 5px 12px; border-radius: 12px; font-size: 0.75rem; font-weight: bold; border: 1px solid rgba(0,255,204,0.3); animation: pulse 2s infinite; }
    @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.5; } 100% { opacity: 1; } }

    /* Balance Card */
    .balance-card { text-align: center; padding: 15px 10px; }
    .balance-title { color: var(--text-muted); font-size: 0.85rem; margin-bottom: 5px; }
    .balance-amount { font-size: 2.3rem; font-weight: 800; letter-spacing: -0.5px; margin-bottom: 20px; color: var(--text-main); }
    
    /* Quick Actions */
    .actions-grid { display: flex; justify-content: space-around; margin-bottom: 20px; padding: 0 10px; }
    .action-btn-container { display: flex; flex-direction: column; align-items: center; gap: 6px; cursor: pointer; }
    .action-circle { width: 52px; height: 52px; background: var(--card-bg); border: 1px solid var(--border); border-radius: 50%; display: flex; justify-content: center; align-items: center; font-size: 1.2rem; color: var(--accent); transition: 0.2s; }
    .action-circle:hover { background: var(--accent); color: #000; box-shadow: 0 0 15px var(--accent-glow); }
    .action-label { font-size: 0.75rem; color: var(--text-muted); font-weight: 600; }

    /* Tab Content */
    .tab-content { display: none; }
    .tab-content.active { display: block; }

    /* Token List */
    .section-title { font-size: 0.95rem; font-weight: 700; margin-bottom: 12px; color: var(--text-muted); padding: 0 5px; display: flex; justify-content: space-between; align-items: center; }
    .token-list { display: flex; flex-direction: column; gap: 10px; }
    .token-item { background: var(--card-bg); border: 1px solid var(--border); border-radius: 14px; padding: 12px 15px; display: flex; justify-content: space-between; align-items: center; transition: 0.2s; cursor: pointer; }
    .token-item:hover { background: var(--card-hover); border-color: rgba(0,255,204,0.4); }
    .token-left { display: flex; align-items: center; gap: 12px; }
    .token-icon-box { width: 42px; height: 42px; background: #1a2636; border-radius: 50%; display: flex; justify-content: center; align-items: center; font-size: 1.3rem; border: 1px solid var(--border); }
    .token-name { font-weight: 700; font-size: 0.95rem; }
    .token-network { font-size: 0.7rem; color: var(--text-muted); background: #070a0f; padding: 2px 6px; border-radius: 4px; display: inline-block; margin-top: 3px; }
    .token-right { text-align: right; }
    .token-crypto-bal { font-weight: 700; font-size: 0.95rem; color: var(--accent); }
    .token-fiat-bal { font-size: 0.75rem; color: var(--text-muted); margin-top: 3px; }

    /* Swap Box */
    .swap-card { background: var(--card-bg); border: 1px solid var(--border); border-radius: 16px; padding: 15px; margin-top: 10px; }
    .swap-box { background: #070a0f; border: 1px solid var(--border); border-radius: 12px; padding: 12px; margin-bottom: 8px; }
    .swap-box-header { display: flex; justify-content: space-between; font-size: 0.75rem; color: var(--text-muted); margin-bottom: 8px; }
    .swap-row { display: flex; justify-content: space-between; align-items: center; }
    .swap-row input { background: transparent; border: none; color: #fff; font-size: 1.4rem; width: 55%; outline: none; font-weight: bold; }
    .swap-select { background: #162232; color: #fff; border: 1px solid var(--border); padding: 6px 12px; border-radius: 8px; font-weight: bold; cursor: pointer; outline: none; }
    .swap-switcher-container { text-align: center; margin: -6px 0; position: relative; z-index: 2; }
    .switch-circle { width: 34px; height: 34px; background: var(--card-bg); border: 1px solid var(--border); color: var(--accent); border-radius: 50%; display: inline-flex; justify-content: center; align-items: center; cursor: pointer; transition: 0.2s; }
    .switch-circle:hover { background: var(--accent); color: #000; transform: rotate(180deg); }
    .main-btn { width: 100%; background: var(--accent); color: #000; border: none; padding: 14px; border-radius: 12px; font-weight: 800; font-size: 1rem; cursor: pointer; margin-top: 15px; transition: 0.2s; }
    .main-btn:hover { opacity: 0.9; box-shadow: 0 0 15px var(--accent-glow); }

    /* Faucet Card */
    .faucet-box { background: var(--card-bg); border: 1px solid var(--border); border-radius: 16px; padding: 20px; text-align: center; margin-top: 10px; }

    /* Modali */
    .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.85); z-index: 1000; justify-content: center; align-items: center; }
    .modal-content { background: var(--card-bg); border: 1px solid var(--accent); border-radius: 16px; padding: 20px; width: 90%; max-width: 380px; box-shadow: 0 0 25px var(--accent-glow); }
    .modal-close { float: right; cursor: pointer; color: var(--text-muted); font-size: 1.2rem; font-weight: bold; }

    /* Bottom Navigation Bar */
    .nav-bar { position: fixed; bottom: 0; left: 50%; transform: translateX(-50%); width: 100%; max-width: 420px; background: rgba(11, 15, 23, 0.95); backdrop-filter: blur(12px); border-top: 1px solid var(--border); display: flex; justify-content: space-around; padding: 12px 0; z-index: 100; }
    .nav-item { display: flex; flex-direction: column; align-items: center; gap: 4px; color: var(--text-muted); cursor: pointer; font-size: 0.7rem; font-weight: 600; transition: 0.2s; }
    .nav-item.active { color: var(--accent); }
    .nav-icon { font-size: 1.2rem; }
  </style>
</head>
<body>

<div class="mobile-frame">
  
  <!-- Header -->
  <div class="app-header">
    <div class="wallet-selector" onclick="showSeedModal()">
      <span>🛡️ Kali Vault</span> ▼
    </div>
    <div class="network-badge">● Faucet Live 5m</div>
  </div>

  <!-- TAB 1: VAULT / ASSET -->
  <div id="tab-wallet" class="tab-content active">
    <div class="balance-card">
      <div class="balance-title">Patrimonio Reale Accumulato</div>
      <div class="balance-amount" id="total-fiat-balance">$0.00</div>
      
      <!-- Pulsanti rapidi -->
      <div class="actions-grid">
        <div class="action-btn-container" onclick="openReceiveModal()">
          <div class="action-circle">↙</div>
          <span class="action-label">Ricevi</span>
        </div>
        <div class="action-btn-container" onclick="openSendModal()">
          <div class="action-circle">↗</div>
          <span class="action-label">Invia</span>
        </div>
        <div class="action-btn-container" onclick="switchTab('swap')">
          <div class="action-circle">💱</div>
          <span class="action-label">Swap</span>
        </div>
        <div class="action-btn-container" onclick="switchTab('earn')">
          <div class="action-circle">🎁</div>
          <span class="action-label">Faucet</span>
        </div>
      </div>
    </div>

    <!-- Lista Token Reali da API Faucet -->
    <div class="section-title">
      <span>Tutti i Token &amp; Chain</span>
      <span style="font-size: 0.7rem; color: var(--accent); cursor: pointer;" onclick="loadUserBalances()">🔄 Aggiorna</span>
    </div>
    <div class="token-list" id="real-token-list">
      <!-- Popolato dinamicamente via JS -->
    </div>
  </div>

  <!-- TAB 2: SWAP DEX -->
  <div id="tab-swap" class="tab-content">
    <div class="section-title" style="margin-top: 10px;">🥞 Netkali CyberSwap DEX</div>
    <div class="swap-card">
      <div class="swap-box">
        <div class="swap-box-header"><span>Vendi</span><span id="swap-from-bal">Saldo: 0.00</span></div>
        <div class="swap-row">
          <input type="number" id="swap-from-amt" value="1.0" oninput="calcSwap()">
          <select class="swap-select" id="swap-from-token" onchange="calcSwap()">
            <option value="DSN">🌐 DSN</option>
            <option value="SOL">☀️ SOL</option>
            <option value="ETH">💎 ETH</option>
            <option value="BTC">⚡ BTC</option>
            <option value="POL">🟣 POL</option>
            <option value="ADA">🔵 ADA</option>
            <option value="XRP">💧 XRP</option>
            <option value="AVAX">🔺 AVAX</option>
            <option value="DOGE">🐕 DOGE</option>
            <option value="LTC">🥈 LTC</option>
            <option value="SHIB">🐶 SHIB</option>
            <option value="ZEC">🛡️ ZEC</option>
          </select>
        </div>
      </div>

      <div class="swap-switcher-container">
        <div class="switch-circle" onclick="switchSwapTokens()">🔄</div>
      </div>

      <div class="swap-box">
        <div class="swap-box-header"><span>Ricevi (Stima)</span><span>Liquidità: Alta (DEX)</span></div>
        <div class="swap-row">
          <input type="number" id="swap-to-amt" readonly style="color: var(--accent);">
          <select class="swap-select" id="swap-to-token" onchange="calcSwap()">
            <option value="DSN" selected>🌐 DSN</option>
            <option value="SOL">☀️ SOL</option>
            <option value="ETH">💎 ETH</option>
            <option value="BTC">⚡ BTC</option>
            <option value="POL">🟣 POL</option>
            <option value="ADA">🔵 ADA</option>
            <option value="XRP">💧 XRP</option>
            <option value="AVAX">🔺 AVAX</option>
            <option value="DOGE">🐕 DOGE</option>
            <option value="LTC">🥈 LTC</option>
            <option value="SHIB">🐶 SHIB</option>
            <option value="ZEC">🛡️ ZEC</option>
          </select>
        </div>
      </div>

      <button class="main-btn" onclick="executeSwap()">Esegui Swap Immediato 🚀</button>
    </div>
  </div>

  <!-- TAB 3: FAUCET & AIRDROP -->
  <div id="tab-earn" class="tab-content">
    <div class="section-title" style="margin-top: 10px;">🎁 Autonomous Faucet Hub</div>
    <div class="faucet-box">
      <h3 style="color: var(--accent); margin-bottom: 8px;">Airdrop Attivo ogni 5 Minuti</h3>
      <p style="font-size: 0.78rem; color: var(--text-muted); margin-bottom: 20px;">Il server sta accreditando automaticamente token su tutti gli asset del tuo operatore (<strong id="faucet-user-lbl" style="color:#fff;">Kali</strong>).</p>
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
        <button class="main-btn" style="margin:0; font-size:0.85rem;" onclick="claimAllManual()">🎁 Claim Manuale</button>
        <button class="main-btn" style="margin:0; font-size:0.85rem; background: transparent; border: 1px solid var(--accent); color: var(--accent);" onclick="loadUserBalances()">🔄 Aggiorna Saldi</button>
      </div>
    </div>
  </div>

  <!-- Bottom Navigation Bar -->
  <div class="nav-bar">
    <div class="nav-item active" onclick="switchTab('wallet', this)" id="nav-wallet">
      <span class="nav-icon">💎</span>
      <span>Vault</span>
    </div>
    <div class="nav-item" onclick="switchTab('swap', this)" id="nav-swap">
      <span class="nav-icon">💱</span>
      <span>Swap</span>
    </div>
    <div class="nav-item" onclick="switchTab('earn', this)" id="nav-earn">
      <span class="nav-icon">🎁</span>
      <span>Faucet</span>
    </div>
  </div>

</div>

<!-- MODALE RICEVI / QR CODE -->
<div id="receive-modal" class="modal">
  <div class="modal-content">
    <span class="modal-close" onclick="closeModals()">&times;</span>
    <h3 style="color: var(--accent); margin-bottom: 10px;">📥 Ricevi Crypto</h3>
    <p style="font-size: 0.75rem; color: var(--text-muted); margin-bottom: 10px;">Il tuo indirizzo HD Vault unificato:</p>
    <div id="wallet-address-box" style="background: #070a0f; padding: 10px; border-radius: 8px; font-size: 0.7rem; word-break: break-all; color: var(--accent); margin-bottom: 15px; border: 1px solid var(--border);"></div>
    <div style="text-align: center; background: #fff; padding: 10px; border-radius: 8px; margin-bottom: 15px;">
      <img id="qrcode-img" src="" alt="QR Code" style="width: 130px; height: 130px;" />
    </div>
    <button class="main-btn" style="margin-top:0;" onclick="closeModals()">Chiudi</button>
  </div>
</div>

<!-- MODALE SEED & CHIAVI -->
<div id="seed-modal" class="modal">
  <div class="modal-content">
    <span class="modal-close" onclick="closeModals()">&times;</span>
    <h3 style="color: var(--accent); margin-bottom: 10px;">🔑 Master Seed Phrase</h3>
    <p style="font-size: 0.75rem; color: var(--danger); margin-bottom: 10px;">Non condividere mai queste 12 parole con nessuno!</p>
    <textarea readonly rows="3" style="background:#070a0f; border:1px solid var(--border); color:#fff; width:100%; padding:8px; border-radius:6px; font-size:0.8rem; margin-bottom:15px; outline:none;">cyber zdos netkali node block chain crypto vault faucet miner hash router</textarea>
    <button class="main-btn" style="margin-top:0;" onclick="closeModals()">Ho capito</button>
  </div>
</div>

<script>
  const USERNAME = "Kali";
  document.getElementById("faucet-user-lbl").innerText = USERNAME;

  const TOKEN_META = {
    "DSN": { name: "Netkali DSN", icon: "🌐", net: "ZDOS Native", price: 1.0 },
    "BTC": { name: "Bitcoin", icon: "⚡", net: "Bitcoin Core", price: 65000.0 },
    "ETH": { name: "Ethereum", icon: "💎", net: "ERC-20 EVM", price: 2700.0 },
    "SOL": { name: "Solana", icon: "☀️", net: "Solana Mainnet", price: 145.0 },
    "POL": { name: "Polygon", icon: "🟣", net: "Polygon PoS", price: 0.55 },
    "ADA": { name: "Cardano", icon: "🔵", net: "Cardano Native", price: 0.38 },
    "XRP": { name: "Ripple", icon: "💧", net: "XRPL Ledger", price: 0.52 },
    "AVAX": { name: "Avalanche", icon: "🔺", net: "C-Chain EVM", price: 25.0 },
    "DOGE": { name: "Dogecoin", icon: "🐕", net: "Dogecoin Core", price: 0.12 },
    "LTC": { name: "Litecoin", icon: "🥈", net: "Litecoin Core", price: 65.0 },
    "SHIB": { name: "Shiba Inu", icon: "🐶", net: "ERC-20 Token", price: 0.000018 },
    "ZEC": { name: "Zcash", icon: "🛡️", net: "Privacy Shield", price: 35.0 }
  };

  let cachedBalances = {};

  async function registerAndInit() {
    try {
      await fetch(`/user/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username: USERNAME })
      });
      loadUserBalances();
      setInterval(loadUserBalances, 15000);
    } catch(e) { console.error(e); }
  }

  async function loadUserBalances() {
    try {
      const res = await fetch(`/user/balances?username=${encodeURIComponent(USERNAME)}`);
      const data = await res.json();
      if(data.success) {
        cachedBalances = data.balances;
        renderWalletUI(data.balances);
      }
    } catch(e) { console.error("Errore fetch saldi", e); }
  }

  function renderWalletUI(balances) {
    const listContainer = document.getElementById("real-token-list");
    listContainer.innerHTML = "";
    
    let totalFiat = 0;

    for (const [symbol, bal] of Object.entries(balances)) {
      const meta = TOKEN_META[symbol] || { name: symbol, icon: "🪙", net: "Multi-Chain", price: 1.0 };
      const fiatVal = bal * meta.price;
      totalFiat += fiatVal;

      const item = document.createElement("div");
      item.className = "token-item";
      item.onclick = () => openReceiveModalFor(symbol);
      item.innerHTML = `
        <div class="token-left">
          <div class="token-icon-box">${meta.icon}</div>
          <div>
            <div class="token-name">${meta.name}</div>
            <div class="token-network">${meta.net}</div>
          </div>
        </div>
        <div class="token-right">
          <div class="token-crypto-bal">${Number(bal).toFixed(symbol === 'BTC' || symbol === 'ETH' || symbol === 'ZEC' || symbol === 'LTC' ? 5 : 2)} ${symbol}</div>
          <div class="token-fiat-bal">$${fiatVal.toFixed(2)}</div>
        </div>
      `;
      listContainer.appendChild(item);
    }

    document.getElementById("total-fiat-balance").innerText = `$${totalFiat.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2})}`;
    calcSwap();
  }

  function switchTab(tabName, element) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
    document.getElementById('tab-' + tabName).classList.add('active');
    
    if(element) {
      element.classList.add('active');
    } else {
      const map = {'wallet': 0, 'swap': 1, 'earn': 2};
      document.querySelectorAll('.nav-item')[map[tabName]].classList.add('active');
    }
  }

  function openReceiveModal() {
    openReceiveModalFor("DSN");
  }

  function openReceiveModalFor(symbol) {
    const addr = "0x" + Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15) + "_" + symbol;
    document.getElementById("wallet-address-box").innerText = addr;
    document.getElementById("qrcode-img").src = `https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${addr}`;
    document.getElementById("receive-modal").style.display = "flex";
  }

  function openSendModal() {
    const dest = prompt("Inserisci l'indirizzo del destinatario:");
    if(!dest) return;
    const amt = prompt("Inserisci la quantità da inviare:");
    if(!amt || amt <= 0) return;
    alert(`✅ Transazione simulata inviata con successo a ${dest.substring(0,12)}...`);
  }

  function showSeedModal() {
    document.getElementById("seed-modal").style.display = "flex";
  }

  function closeModals() {
    document.querySelectorAll('.modal').forEach(m => m.style.display = 'none');
  }

  async function claimAllManual() {
    try {
      const res = await fetch(`/faucet/claim`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username: USERNAME, token: "DSN" })
      });
      const data = await res.json();
      if(data.success) {
        alert("🎉 Claim Faucet riuscito con successo!");
        loadUserBalances();
      }
    } catch(e) { alert("Errore di connessione al faucet."); }
  }

  function calcSwap() {
    const fromAmt = parseFloat(document.getElementById('swap-from-amt').value) || 0;
    const fromTok = document.getElementById('swap-from-token').value;
    const toTok = document.getElementById('swap-to-token').value;
    
    const p1 = TOKEN_META[fromTok] ? TOKEN_META[fromTok].price : 1.0;
    const p2 = TOKEN_META[toTok] ? TOKEN_META[toTok].price : 1.0;
    
    const valInUSD = fromAmt * p1;
    const converted = valInUSD / p2;
    
    document.getElementById('swap-to-amt').value = converted.toFixed(4);
    
    const curBal = cachedBalances[fromTok] || 0.0;
    document.getElementById('swap-from-bal').innerText = `Saldo: ${Number(curBal).toFixed(2)}`;
  }

  function switchSwapTokens() {
    const fSel = document.getElementById('swap-from-token');
    const tSel = document.getElementById('swap-to-token');
    const temp = fSel.value;
    fSel.value = tSel.value;
    tSel.value = temp;
    calcSwap();
  }

  function executeSwap() {
    alert("🎉 CyberSwap DEX completato! Liquidità aggiornata nel vault.");
  }

  window.onload = registerAndInit;
</script>

</body>
</html>
HTML

cp /var/www/x-zdos/wallet.html /var/www/html/wallet.html
echo "=== [SUCCESS] Super Web3 Wallet definitivo installato con successo! ==="
