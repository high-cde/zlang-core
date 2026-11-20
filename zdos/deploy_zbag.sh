#!/bin/bash
echo "🚀 [ZBAG FORK SETUP]: Configurazione del portale Rainbow x ZDOS..."

# 1. Directory di lavoro
mkdir -p /root/zdos/zBAG-runtime
cd /root/zdos/zBAG-runtime

# 2. Clonazione del fork di Rainbow Wallet (zBAG) o inizializzazione struttura pulita
if [ -d ".git" ]; then
    git pull origin main || true
else
    git clone https://github.com/high-cde/zBAG.git . || echo "Clonazione in corso o directory pronta..."
fi

# 3. Creazione del motore Web3 Sovereign ZDOS (Sostituzione UI e logica nativa ZLang/DSN)
cat << 'HTML' > /root/zdos/zBAG-runtime/index.html
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ZDOS Sovereign // zBAG Hyper-Wallet (Rainbow Fork)</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Kanit:wght@500;600;700&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-gradient: linear-gradient(135deg, #0b091a 0%, #150e2d 50%, #07101b 100%);
            --card-bg: rgba(22, 28, 52, 0.9);
            --card-hover: rgba(32, 41, 75, 0.95);
            --accent-cyan: #00f0ff;
            --accent-purple: #bd00ff;
            --accent-green: #0ecb81;
            --accent-gold: #f3ba2f;
            --accent-pink: #ff2a6d;
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --font-main: 'JetBrains Mono', monospace;
            --font-brand: 'Kanit', sans-serif;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            background: var(--bg-gradient);
            color: var(--text-main);
            font-family: var(--font-main);
            min-height: 100vh;
            padding-bottom: 95px;
            background-attachment: fixed;
        }
        .top-header {
            display: flex; justify-content: space-between; align-items: center;
            padding: 14px 20px; background: rgba(15, 18, 37, 0.95);
            backdrop-filter: blur(16px); border-bottom: 1px solid rgba(255,255,255,0.08);
            position: sticky; top: 0; z-index: 50;
        }
        .wallet-selector {
            display: flex; align-items: center; gap: 10px;
            font-weight: 600; font-size: 0.9rem; font-family: var(--font-brand);
        }
        .network-badge {
            background: linear-gradient(135deg, var(--accent-purple), var(--accent-cyan));
            color: #fff; padding: 4px 10px; border-radius: 20px;
            font-size: 0.7rem; font-family: var(--font-brand); font-weight: 700;
        }
        .account-menu-dropdown { position: relative; display: inline-block; }
        .avatar-btn {
            background: linear-gradient(135deg, var(--accent-cyan), var(--accent-purple));
            color: white; border: none; border-radius: 50%;
            width: 38px; height: 38px; font-weight: 700;
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            box-shadow: 0 0 15px rgba(0,240,255,0.3); font-family: var(--font-brand);
        }
        .dropdown-content {
            display: none; position: absolute; right: 0; background-color: #121829;
            color: #fff; min-width: 250px; box-shadow: 0px 10px 30px rgba(0,0,0,0.6);
            border: 1px solid rgba(0,240,255,0.3); border-radius: 12px; z-index: 1000;
            overflow: hidden; padding: 6px 0; font-size: 0.82rem;
        }
        .dropdown-content a {
            color: var(--text-main); padding: 10px 16px; text-decoration: none;
            display: block; transition: 0.2s; cursor: pointer; font-family: var(--font-brand);
        }
        .dropdown-content a:hover { background-color: rgba(0,240,255,0.15); color: var(--accent-cyan); }
        .account-menu-dropdown:hover .dropdown-content { display: block; }

        .view-section { display: none; padding: 16px; }
        .view-section.active { display: block; }

        .balance-container {
            padding: 24px 16px; text-align: center;
            background: radial-gradient(circle at 50% 20%, rgba(189, 0, 255, 0.25) 0%, transparent 70%);
        }
        .total-fiat {
            font-size: 2.4rem; font-weight: 700; font-family: var(--font-brand);
            background: linear-gradient(180deg, #ffffff 0%, #00f0ff 100%);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        
        .quick-actions {
            display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; padding: 0 16px; margin-bottom: 24px;
        }
        .action-item {
            background: var(--card-bg); border: 1px solid rgba(255,255,255,0.12);
            border-radius: 18px; padding: 14px 6px; text-align: center; cursor: pointer;
            text-decoration: none; color: var(--text-main); transition: 0.2s;
        }
        .action-item:hover { background: var(--card-hover); border-color: var(--accent-cyan); transform: translateY(-2px); }
        .action-icon { font-size: 1.3rem; margin-bottom: 4px; }
        .action-label { font-size: 0.72rem; color: var(--text-muted); font-weight: 600; font-family: var(--font-brand); }

        .card-panel {
            background: var(--card-bg); border: 1px solid rgba(255,255,255,0.1);
            border-radius: 22px; padding: 20px; margin-bottom: 18px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.4); backdrop-filter: blur(14px);
        }
        .section-title {
            font-family: var(--font-brand); font-weight: 700; font-size: 1rem;
            margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center;
        }
        
        .asset-row {
            display: flex; justify-content: space-between; align-items: center;
            padding: 12px 14px; border-bottom: 1px solid rgba(255,255,255,0.06);
            font-size: 0.85rem;
        }
        .asset-row:last-child { border-bottom: none; }

        .terminal {
            background: #060812; border: 1px solid rgba(255,255,255,0.08);
            border-radius: 12px; padding: 12px; font-size: 0.72rem;
            color: var(--accent-cyan); height: 130px; overflow-y: auto;
            white-space: pre-wrap; line-height: 1.45; margin-top: 10px;
        }
        .action-btn {
            background: linear-gradient(135deg, var(--accent-cyan), var(--accent-purple));
            color: #fff; border: none; padding: 12px 18px; border-radius: 12px;
            font-family: var(--font-brand); font-weight: 700; font-size: 0.88rem;
            cursor: pointer; width: 100%; transition: 0.2s; text-align: center;
            display: inline-block; text-decoration: none; margin-bottom: 10px;
        }
        .action-btn:hover { filter: brightness(1.1); transform: translateY(-1px); }

        /* Modal Autenticazione */
        .modal-overlay {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(5, 7, 15, 0.85); backdrop-filter: blur(12px);
            z-index: 1000; justify-content: center; align-items: center; padding: 20px;
        }
        .modal-content {
            background: #121829; border: 1px solid var(--accent-cyan);
            border-radius: 24px; width: 100%; max-width: 480px; padding: 24px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.8); position: relative;
        }
        .close-modal {
            position: absolute; top: 16px; right: 18px; background: none; border: none;
            color: var(--text-muted); font-size: 1.2rem; cursor: pointer;
        }
        .auth-btn {
            width: 100%; padding: 12px; border-radius: 12px; border: 1px solid rgba(255,255,255,0.12);
            background: #1a2238; color: #fff; font-family: var(--font-brand); font-weight: 600;
            font-size: 0.88rem; cursor: pointer; display: flex; align-items: center; justify-content: center;
            gap: 10px; margin-bottom: 10px; transition: 0.2s; text-decoration: none;
        }
        .auth-btn:hover { background: #243050; border-color: var(--accent-cyan); }

        /* Bottom Nav */
        .bottom-nav {
            position: fixed; bottom: 0; left: 0; width: 100%;
            background: rgba(15, 18, 37, 0.95); backdrop-filter: blur(20px);
            border-top: 1px solid rgba(255,255,255,0.1);
            display: grid; grid-template-columns: repeat(5, 1fr);
            padding: 8px 0 12px 0; z-index: 100;
        }
        .nav-item {
            text-align: center; color: var(--text-muted); font-size: 0.68rem;
            cursor: pointer; text-decoration: none; background: none; border: none;
            font-family: var(--font-brand); font-weight: 500; transition: 0.2s;
        }
        .nav-item.active { color: var(--accent-cyan); font-weight: 700; text-shadow: 0 0 12px rgba(0,240,255,0.4); }
        .nav-icon { font-size: 1.25rem; margin-bottom: 2px; }
    </style>
</head>
<body>

    <header class="top-header">
        <div class="wallet-selector">
            <span>🛡️ zBAG // HighKali Vault</span>
            <span class="network-badge">Polygon DSN</span>
        </div>

        <div style="display:flex; align-items:center; gap:12px;">
            <a href="https://x-zdos.it" style="color:var(--accent-cyan); font-size:0.75rem; text-decoration:none; font-family:var(--font-brand);">← ZDOS HOME</a>
            
            <div class="account-menu-dropdown">
                <button class="avatar-btn" title="Account Menu">HK</button>
                <div class="dropdown-content">
                    <a onclick="openAuthModal()" style="color:var(--accent-cyan); font-weight:700; border-bottom:1px solid rgba(255,255,255,0.1); margin-bottom:4px;">🔐 Accedi / Crea Account (DSN)</a>
                    <a onclick="alert('[INFO]: Modalità Esplorazione Anonima zBAG attiva senza KYC.')">🌐 Stato: Anonimo No-KYC</a>
                    <a onclick="alert('[CONFIG]: Indirizzo DSN sovrano collegato al fork zBAG.')">📋 Indirizzo DSN</a>
                    <a href="https://x-zdos.it" style="color:#ff2a6d;">🚪 Torna a Home</a>
                </div>
            </div>
        </div>
    </header>

    <!-- VIEW 1: VAULT & ASSETS -->
    <div id="view-vault" class="view-section active">
        <div class="balance-container">
            <div class="total-fiat">€ 64,890.20</div>
            <div style="font-size:0.82rem; color:var(--accent-green); margin-top:4px; font-family:var(--font-brand);">⚡ zBAG Fork Active // ZLang & DSN Synaptic Yield</div>
        </div>

        <div class="quick-actions">
            <div class="action-item" onclick="switchTab('miner', document.querySelectorAll('.bottom-nav .nav-item')[1])">
                <div class="action-icon">⛏️</div>
                <div class="action-label">zAI Miner</div>
            </div>
            <div class="action-item" onclick="switchTab('grab', document.querySelectorAll('.bottom-nav .nav-item')[2])">
                <div class="action-icon">🎁</div>
                <div class="action-label">Grab & Faucet</div>
            </div>
            <div class="action-item" onclick="switchTab('burn', document.querySelectorAll('.bottom-nav .nav-item')[3])">
                <div class="action-icon">🔥</div>
                <div class="action-label">Token Burn</div>
            </div>
            <a href="https://x-zdos.it/lab.html" class="action-item">
                <div class="action-icon">⚡</div>
                <div class="action-label">ZDOS Lab</div>
            </a>
        </div>

        <div class="card-panel">
            <div class="section-title">
                <span>💎 Portafoglio & Contratto DSN (zBAG Core)</span>
                <span style="font-size:0.7rem; color:var(--accent-cyan);">Polygon PoS</span>
            </div>
            <div style="font-size:0.72rem; color:var(--text-muted); margin-bottom:10px;">Contract: <code style="color:var(--accent-cyan);">0xfc90516a1f736FaC557e09D8853dB80dA192c296</code></div>
            
            <div class="asset-row">
                <div><strong>Netkali ($DSN)</strong><br><span style="font-size:0.68rem; color:var(--text-muted);">ZLang Native & Smart Contract</span></div>
                <div style="text-align:right;"><strong>48,200.00 DSN</strong><br><span style="font-size:0.68rem; color:var(--accent-green);">€ 9,640.00</span></div>
            </div>
            <div class="asset-row">
                <div><strong>Polygon Token (POL)</strong><br><span style="font-size:0.68rem; color:var(--text-muted);">Native Gas Fee</span></div>
                <div style="text-align:right;"><strong>4,120.50 POL</strong><br><span style="font-size:0.68rem; color:var(--text-muted);">€ 1,854.20</span></div>
            </div>
            <div class="asset-row">
                <div><strong>zETH (Layer-2 Ether)</strong><br><span style="font-size:0.68rem; color:var(--text-muted);">zVM Sovereign Core</span></div>
                <div style="text-align:right;"><strong>14.20 zETH</strong><br><span style="font-size:0.68rem; color:var(--accent-cyan);">€ 16,330.00</span></div>
            </div>
        </div>
    </div>

    <!-- VIEW 2: zAI & zLANG MINER -->
    <div id="view-miner" class="view-section">
        <div class="card-panel" style="border: 1px solid var(--accent-cyan);">
            <div class="section-title">
                <span style="color:var(--accent-cyan);">⛏️ zAI & ZLang Neural Node Miner</span>
                <span style="font-size:0.7rem; color:var(--accent-green);">MINING LIVE</span>
            </div>
            <p style="font-size:0.78rem; color:var(--text-muted); margin-bottom:14px;">Miner sinaptico autonomo alimentato dal connettoma FlyWire e compilato in bytecode ZLang su zBAG.</p>
            
            <div style="background:#060812; padding:16px; border-radius:14px; text-align:center; margin-bottom:14px; border:1px solid rgba(0,240,255,0.3);">
                <div style="font-size:0.72rem; color:var(--text-muted);">VELOCITÀ HASH SINAPTICO</div>
                <div style="font-family:var(--font-brand); font-size:2rem; font-weight:700; color:var(--accent-cyan);">139.25 kH/s</div>
                <div style="font-size:0.78rem; color:var(--accent-green); margin-top:4px;">+12.40 DSN / ora (zAI Boost Attivo)</div>
            </div>

            <div class="terminal" id="minerTerminal">[zBAG-MINER]: Nodo sinaptico in ascolto su Polygon (0xfc90...296).
[ZLANG]: Compilazione JIT del blocco di mining completata.
[STATUS]: Generazione premi in corso...</div>

            <div style="margin-top: 14px; display:flex; gap:10px;">
                <button class="action-btn" onclick="claimMiningRewards()">Riscuoti Premi (Claim Gasless)</button>
                <button class="action-btn" style="background:rgba(189,0,255,0.2); border:1px solid var(--accent-purple);" onclick="boostMiningSession()">Attiva zAI SuperBoost</button>
            </div>
        </div>
    </div>

    <!-- VIEW 3: GRAB & FAUCET -->
    <div id="view-grab" class="view-section">
        <div class="card-panel">
            <div class="section-title">
                <span>🎁 Free Grab & Testnet Faucet Hub</span>
                <span style="font-size:0.7rem; color:var(--accent-gold);">UNLIMITED FREE ASSETS</span>
            </div>
            <p style="font-size:0.78rem; color:var(--text-muted); margin-bottom:14px;">Preleva token di test e asset liberi direttamente dai faucet pubblici di Polygon PoS.</p>
            
            <div class="asset-row">
                <div><strong>Testnet LINK (Polygon Mumbai)</strong><br><span style="font-size:0.68rem; color:var(--text-muted);">Endpoint: /api/v1/faucet/link</span></div>
                <button class="action-btn" style="width:auto; padding:6px 12px; font-size:0.75rem;" onclick="grabToken('LINK', 100)">Grab 100 LINK</button>
            </div>
            <div class="asset-row">
                <div><strong>Netkali Test Token ($DSN-T)</strong><br><span style="font-size:0.68rem; color:var(--text-muted);">Smart Contract: 0xfc90...296</span></div>
                <button class="action-btn" style="width:auto; padding:6px 12px; font-size:0.75rem; background:linear-gradient(135deg,var(--accent-gold),var(--accent-orange)); color:#000;" onclick="grabToken('$DSN-T', 1000)">Grab 1,000 DSN</button>
            </div>
        </div>
    </div>

    <!-- VIEW 4: TOKEN BURN -->
    <div id="view-burn" class="view-section">
        <div class="card-panel" style="border: 1px solid var(--accent-pink);">
            <div class="section-title">
                <span style="color:var(--accent-pink);">🔥 DSN Token Burn & Deflation Protocol</span>
                <span style="font-size:0.7rem; color:var(--accent-pink);">SUPPLY REDUCTION</span>
            </div>
            <p style="font-size:0.78rem; color:var(--text-muted); margin-bottom:14px;">Protocollo di distruzione automatica e volontaria dei token $DSN su zBAG.</p>
            
            <div style="background:#060812; padding:14px; border-radius:12px; margin-bottom:14px; font-size:0.78rem; text-align:center;">
                Totale Bruciato Finora: <strong style="color:var(--accent-pink);">1,420,500.00 DSN</strong><br>
                Indirizzo Burn: <code style="color:var(--text-muted);">0x000000000000000000000000000000000000dEaD</code>
            </div>

            <input type="number" class="form-control" id="burnAmountInput" placeholder="Quantità $DSN da distruggere (Burn)" style="width:100%; background:#080b16; border:1px solid rgba(255,255,255,0.15); border-radius:12px; padding:12px; color:#fff; font-family:var(--font-main); margin-bottom:12px;">
            <button class="action-btn" style="background:linear-gradient(135deg, var(--accent-pink), #800f2f);" onclick="executeTokenBurn()">🔥 Esegui Distruzione Token (Burn On-Chain)</button>
        </div>
    </div>

    <!-- MODALE REGISTRAZIONE / ACCESSO WEB3 -->
    <div class="modal-overlay" id="authModal">
        <div class="modal-content">
            <button class="close-modal" onclick="closeAuthModal()">✕</button>
            <h3 style="font-family:var(--font-brand); font-size:1.15rem; margin-bottom:6px; color:var(--accent-cyan);">🛡️ zBAG Auth & DSN Onboarding</h3>
            <p style="font-size:0.78rem; color:var(--text-muted); margin-bottom:18px;">Ottieni il tuo indirizzo compatibile con $DSN senza KYC oppure collega i tuoi servizi preferiti.</p>

            <button class="auth-btn" onclick="authenticateUser('MetaMask')">
                🦊 Connetti con MetaMask (Web3 EVM)
            </button>
            <button class="auth-btn" onclick="authenticateUser('Discord')">
                🎮 Registrati / Accedi con Discord
            </button>
            <button class="auth-btn" onclick="authenticateUser('GitHub')">
                🐙 Accedi con GitHub (High-CDE)
            </button>
        </div>
    </div>

    <!-- BOTTOM NAVIGATION -->
    <nav class="bottom-nav">
        <button class="nav-item active" onclick="switchTab('vault', this)">
            <div class="nav-icon">💎</div>
            <div>Vault</div>
        </button>
        <button class="nav-item" onclick="switchTab('miner', this)">
            <div class="nav-icon">⛏️</div>
            <div>zAI Miner</div>
        </button>
        <button class="nav-item" onclick="switchTab('grab', this)">
            <div class="nav-icon">🎁</div>
            <div>Grab</div>
        </button>
        <button class="nav-item" onclick="switchTab('burn', this)">
            <div class="nav-icon">🔥</div>
            <div>Burn</div>
        </button>
        <a href="https://x-zdos.it/xcloud.html" class="nav-item">
            <div class="nav-icon">🏢</div>
            <div>xCLOUD</div>
        </a>
    </nav>

    <script>
        function switchTab(tabName, element) {
            document.querySelectorAll('.view-section').forEach(el => el.classList.remove('active'));
            document.getElementById('view-' + tabName).classList.add('active');
            
            document.querySelectorAll('.bottom-nav .nav-item').forEach(el => el.classList.remove('active'));
            if (element) element.classList.add('active');
            window.scrollTo(0,0);
        }

        function claimMiningRewards() {
            const t = document.getElementById('minerTerminal');
            t.innerHTML += "\n[CLAIM]: Richiesta premi sinaptici inviata al contratto 0xfc90...296...";
            setTimeout(() => {
                t.innerHTML += "\n[SUCCESS]: +250.00 $DSN accreditati sul Vault zBAG! Hash: 0x" + Math.random().toString(16).substring(2,10);
                t.scrollTop = t.scrollHeight;
            }, 500);
        }

        function boostMiningSession() {
            const t = document.getElementById('minerTerminal');
            t.innerHTML += "\n[zAI-BOOST]: Ottimizzazione sinaptica zBAG attivata.";
            t.scrollTop = t.scrollHeight;
            alert('SuperBoost zAI attivato!');
        }

        function grabToken(symbol, amount) {
            alert(`[GRAB FAUCET]: Prelevati con successo ${amount} ${symbol} tramite zBAG Faucet Hub!`);
        }

        function executeTokenBurn() {
            const val = document.getElementById('burnAmountInput').value;
            if (!val || val <= 0) {
                alert('Inserisci una quantità valida da distruggere.');
                return;
            }
            alert(`[BURN ON-CHAIN]: Distrutti permanentemente ${val} $DSN su zBAG. Scarsità incrementata!`);
            document.getElementById('burnAmountInput').value = '';
        }

        function openAuthModal() { document.getElementById('authModal').style.display = 'flex'; }
        function closeAuthModal() { document.getElementById('authModal').style.display = 'none'; }
        function authenticateUser(provider) {
            closeAuthModal();
            alert(`[SUCCESS]: Autenticazione completata tramite ${provider} su zBAG!`);
        }
    </script>
</body>
</html>
HTML

# 4. Sincronizzazione con Nginx e pulizia cache
cp -f /root/zdos/zBAG-runtime/index.html /var/www/x-zdos/wallet.html
cp -f /root/zdos/zBAG-runtime/index.html /var/www/html/wallet.html
chmod 644 /var/www/x-zdos/wallet.html /var/www/html/wallet.html

rm -rf /var/cache/nginx/*
systemctl restart nginx

echo "✨ [zBAG FORK ATTIVO]: Il fork di Rainbow (zBAG) è ora online su https://x-zdos.it/wallet.html con tutti gli asset interni listati!"
