#!/bin/bash
set -e

echo "=== [ZDOS] Deploy della sezione CyberSwap DEX in corso ==="

# Creazione o aggiornamento della pagina swap.html
cat << 'HTML_EOF' > /var/www/x-zdos/swap.html
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ZDOS // Netkali CyberSwap DEX</title>
  <style>
    body { background: #0a0d10; color: #00ffcc; font-family: 'Courier New', Courier, monospace; margin: 0; padding: 20px; }
    .zdos-swap-container { background: #0a0d10; color: #00ffcc; font-family: 'Courier New', Courier, monospace; padding: 20px; border: 1px solid #00ffcc33; border-radius: 8px; max-width: 480px; margin: 20px auto; box-shadow: 0 0 20px rgba(0, 255, 204, 0.05); }
    .swap-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid #00ffcc22; padding-bottom: 10px; }
    .swap-title-area h2 { font-size: 1.1rem; margin: 0; color: #fff; }
    .swap-subtitle { font-size: 0.7rem; color: #88a0c0; margin: 4px 0 0 0; }
    .swap-mode-badge { background: #00ffcc22; color: #00ffcc; padding: 3px 8px; border-radius: 12px; font-size: 0.7rem; border: 1px solid #00ffcc44; }
    .swap-card { background: #111820; border: 1px solid #223344; border-radius: 8px; padding: 15px; margin-bottom: 15px; }
    .swap-input-group { background: #070a0e; border: 1px solid #1a222a; border-radius: 6px; padding: 10px; margin-bottom: 8px; }
    .swap-field-header { display: flex; justify-content: space-between; font-size: 0.75rem; color: #88a0c0; margin-bottom: 6px; }
    .swap-row { display: flex; justify-content: space-between; gap: 10px; }
    .swap-row input { background: transparent; border: none; color: #fff; font-size: 1.4rem; font-family: monospace; width: 50%; outline: none; }
    .swap-row select { background: #16202c; border: 1px solid #334455; color: #00ffcc; padding: 6px 10px; border-radius: 4px; font-family: monospace; font-weight: bold; cursor: pointer; outline: none; }
    .swap-switcher-container { text-align: center; margin: -4px 0; position: relative; z-index: 2; }
    .swap-switch-btn { background: #16202c; border: 1px solid #00ffcc55; color: #00ffcc; width: 32px; height: 32px; border-radius: 50%; cursor: pointer; font-size: 0.9rem; transition: 0.2s; }
    .swap-switch-btn:hover { background: #00ffcc; color: #000; transform: rotate(180deg); }
    .swap-details { background: #070a0e; border-radius: 6px; padding: 10px; font-size: 0.75rem; margin: 15px 0; border: 1px dashed #223344; }
    .detail-row { display: flex; justify-content: space-between; margin-bottom: 4px; color: #88a0c0; }
    .execute-swap-btn { width: 100%; background: linear-gradient(135deg, #00ffcc, #00b388); color: #000; border: none; padding: 12px; font-weight: bold; font-size: 0.95rem; border-radius: 6px; cursor: pointer; font-family: monospace; transition: 0.2s; }
    .execute-swap-btn:hover { opacity: 0.9; box-shadow: 0 0 15px rgba(0,255,204,0.4); }
    .swap-terminal-log { background: #050709; border: 1px solid #222; border-radius: 6px; padding: 10px; font-size: 0.75rem; }
    .log-header { color: #556677; border-bottom: 1px solid #1a222a; padding-bottom: 4px; margin-bottom: 4px; }
    .log-content { color: #88a0c0; max-height: 60px; overflow-y: auto; }
  </style>
</head>
<body>
<div class="zdos-swap-container">
  <div class="swap-header">
    <div class="swap-title-area">
      <h2>🥞 Netkali // CyberSwap DEX</h2>
      <p class="swap-subtitle">Scambia token multi-chain alla velocità della luce</p>
    </div>
    <div class="swap-mode-badge">⚡ Live Testnet</div>
  </div>
  <div class="swap-card">
    <div class="swap-input-group">
      <div class="swap-field-header">
        <span>Vendi / Inserisci</span>
        <span class="wallet-balance-hint">ZDOS Router: <strong id="from-balance">OK</strong></span>
      </div>
      <div class="swap-row">
        <input type="number" id="from-amount" placeholder="0.0" value="1.0" oninput="calculateSwap()" />
        <select id="from-token" onchange="calculateSwap()">
          <option value="DSN">🌐 DSN (Netkali)</option>
          <option value="SOL">☀️ SOL (Solana)</option>
          <option value="ETH">💎 ETH (Ethereum)</option>
          <option value="BTC">⚡ BTC (Bitcoin)</option>
          <option value="POL">🟣 POL (Polygon)</option>
          <option value="ADA">🔵 ADA (Cardano)</option>
          <option value="XRP">💧 XRP (Ripple)</option>
          <option value="AVAX">🔺 AVAX (Avalanche)</option>
          <option value="DOGE">🐕 DOGE (Dogecoin)</option>
          <option value="LTC">🥈 LTC (Litecoin)</option>
          <option value="SHIB">🐶 SHIB (Shiba Inu)</option>
          <option value="ZEC">🛡️ ZEC (Zcash)</option>
        </select>
      </div>
    </div>
    <div class="swap-switcher-container">
      <button class="swap-switch-btn" onclick="switchTokens()" title="Inverti coppie">🔄</button>
    </div>
    <div class="swap-input-group">
      <div class="swap-field-header">
        <span>Ricevi (Stima)</span>
        <span class="wallet-balance-hint">Liquidità: <strong id="to-balance">Alta</strong></span>
      </div>
      <div class="swap-row">
        <input type="number" id="to-amount" placeholder="0.0" readonly />
        <select id="to-token" onchange="calculateSwap()">
          <option value="SOL">☀️ SOL (Solana)</option>
          <option value="DSN" selected>🌐 DSN (Netkali)</option>
          <option value="ETH">💎 ETH (Ethereum)</option>
          <option value="BTC">⚡ BTC (Bitcoin)</option>
          <option value="POL">🟣 POL (Polygon)</option>
          <option value="ADA">🔵 ADA (Cardano)</option>
          <option value="XRP">💧 XRP (Ripple)</option>
          <option value="AVAX">🔺 AVAX (Avalanche)</option>
          <option value="DOGE">🐕 DOGE (Dogecoin)</option>
          <option value="LTC">🥈 LTC (Litecoin)</option>
          <option value="SHIB">🐶 SHIB (Shiba Inu)</option>
          <option value="ZEC">🛡️ ZEC (Zcash)</option>
        </select>
      </div>
    </div>
    <div class="swap-details">
      <div class="detail-row"><span>Tasso di cambio</span> <span id="exchange-rate">1 DSN = 0.05 SOL</span></div>
      <div class="detail-row"><span>Slittamento (Slippage)</span> <span style="color: #00ff66;">0.1% (Liscio)</span></div>
      <div class="detail-row"><span>Commissioni ZDOS</span> <span style="color: #ff0055;">0.00 $ (Gratis zio!)</span></div>
    </div>
    <button class="execute-swap-btn" onclick="executeSwap()">🚀 Esegui Swap Magico</button>
  </div>
  <div class="swap-terminal-log">
    <div class="log-header"><span>DEX_KERNEL // LOG</span></div>
    <div class="log-content" id="swap-log">[00:00:00] Router DEX caricato con successo.</div>
  </div>
</div>
<script>
  const RATES = {
    "DSN": 1.0, "SOL": 0.025, "ETH": 0.00035, "BTC": 0.000015,
    "POL": 0.5, "ADA": 0.4, "XRP": 0.3, "AVAX": 0.015,
    "DOGE": 1.2, "LTC": 0.004, "SHIB": 150.0, "ZEC": 0.002
  };
  function logSwap(msg) {
    const box = document.getElementById("swap-log");
    const time = new Date().toTimeString().split(' ')[0];
    box.innerHTML += `<br>[${time}] ${msg}`;
    box.scrollTop = box.scrollHeight;
  }
  function calculateSwap() {
    const fromVal = parseFloat(document.getElementById("from-amount").value) || 0;
    const fromToken = document.getElementById("from-token").value;
    const toToken = document.getElementById("to-token").value;
    const valInUSD = fromVal / (RATES[fromToken] || 1);
    const converted = valInUSD * (RATES[toToken] || 1);
    document.getElementById("to-amount").value = converted.toFixed(4);
    const rateCalc = (RATES[toToken] / RATES[fromToken]).toFixed(4);
    document.getElementById("exchange-rate").innerText = `1 ${fromToken} = ${rateCalc} ${toToken}`;
  }
  function switchTokens() {
    const fromT = document.getElementById("from-token").value;
    const toT = document.getElementById("to-token").value;
    document.getElementById("from-token").value = toT;
    document.getElementById("to-token").value = fromT;
    calculateSwap();
    logSwap("Invertite le coppie nel router DEX.");
  }
  function executeSwap() {
    const fromVal = document.getElementById("from-amount").value;
    const fromT = document.getElementById("from-token").value;
    const toT = document.getElementById("to-token").value;
    const toVal = document.getElementById("to-amount").value;
    if (fromVal <= 0) { alert("Inserisci un importo valido, bro!"); return; }
    logSwap(`🔄 Swap avviato: ${fromVal} ${fromT} ➔ ${toVal} ${toT}...`);
    setTimeout(() => {
      logSwap(`✅ Swap completato con successo!`);
      alert(`🎉 Fantastico! Scambiati ${fromVal} ${fromT} in ${toVal} ${toT}!`);
    }, 1000);
  }
  window.addEventListener("DOMContentLoaded", () => { calculateSwap(); });
</script>
</body>
</html>
HTML_EOF

cp /var/www/x-zdos/swap.html /var/www/html/swap.html
echo "=== [SUCCESS] Autobuild DEX completato! Pagina disponibile su /swap.html ==="
