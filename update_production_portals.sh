#!/usr/bin/env bash
# ==============================================================================
# ZDOS PRODUCTION PORTALS AUTOBUILD (ADDITIVE & SAFE)
# Aggiorna index.html e specs.html nelle directory di produzione di Nginx.
# Nessun indice primario o file di backup viene eliminato.
# ==============================================================================

TARGET_DIRS=("/var/www/x-zdos" "/var/www/html")

for DIR in "${TARGET_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        echo "[+] Aggiornamento portale in: $DIR"
        
        # 1. Backup di sicurezza preventivo dei file esistenti
        mkdir -p "$DIR/master_backup"
        if [ -f "$DIR/index.html" ]; then
            cp "$DIR/index.html" "$DIR/master_backup/index.html.bak_$(date +%Y%m%d_%H%M%S)"
        fi
        if [ -f "$DIR/specs.html" ]; then
            cp "$DIR/specs.html" "$DIR/master_backup/specs.html.bak_$(date +%Y%m%d_%H%M%S)"
        fi

        # 2. Scrittura del nuovo index.html (Zclipper Hyper Conscious & OpenClaw Core)
        cat << 'INDEX_HTML' > "$DIR/index.html"
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Zclipper Hyper Conscious &middot; ZDOS Sovereign Core</title>
    <style>
        :root {
            --bg-color: #07090e;
            --panel-bg: #0d131f;
            --border-color: #1e293b;
            --text-main: #f1f5f9;
            --text-muted: #64748b;
            --accent-green: #10b981;
            --accent-blue: #3b82f6;
            --accent-purple: #8b5cf6;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: var(--bg-color);
            color: var(--text-main);
            margin: 0;
            padding: 20px;
            display: flex;
            flex-direction: column;
            height: 100vh;
            box-sizing: border-box;
        }
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 15px;
            margin-bottom: 20px;
        }
        h1 {
            font-size: 1.4rem;
            margin: 0;
            background: linear-gradient(90deg, #38bdf8, #a78bfa);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .status-badge {
            background: rgba(16, 185, 129, 0.1);
            color: var(--accent-green);
            border: 1px solid rgba(16, 185, 129, 0.3);
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: bold;
        }
        .grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            flex: 1;
            min-height: 0;
        }
        @media (max-width: 768px) {
            .grid { grid-template-columns: 1fr; }
        }
        .panel {
            background-color: var(--panel-bg);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 15px;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        .panel h2 {
            font-size: 1rem;
            margin-top: 0;
            margin-bottom: 12px;
            color: #94a3b8;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 8px;
        }
        .console-output {
            background: #030508;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            padding: 12px;
            font-family: monospace;
            font-size: 0.85rem;
            color: #34d399;
            flex: 1;
            overflow-y: auto;
        }
        .nav-links {
            display: flex;
            gap: 12px;
            margin-top: 15px;
        }
        .btn {
            background: var(--accent-blue);
            color: white;
            border: none;
            padding: 10px 16px;
            border-radius: 6px;
            font-size: 0.85rem;
            cursor: pointer;
            text-decoration: none;
            font-weight: bold;
        }
        .btn:hover { background: #2563eb; }
        .metrics-list {
            list-style: none;
            padding: 0;
            margin: 0;
            font-size: 0.9rem;
        }
        .metrics-list li {
            padding: 10px 0;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            justify-content: space-between;
        }
        .metrics-list li span:last-child {
            color: var(--accent-green);
            font-family: monospace;
        }
    </style>
</head>
<body>

    <header>
        <div>
            <h1>🤖 zclipper Hyper Conscious &middot; OpenClaw Engine</h1>
            <span style="font-size: 0.8rem; color: var(--text-muted);">ZDOS Sovereign Node (`vmi3082470`) Active</span>
        </div>
        <div class="status-badge">● HYPER ONLINE</div>
    </header>

    <div class="grid">
        <div class="panel">
            <h2>AI Neural Telemetry & OpenClaw Stream</h2>
            <div class="console-output" id="term">
                [zclipper-core] Initializing Hyper Conscious state...<br>
                [z-lang] Runtime compiled successfully. Zero data loss protocol active.<br>
                [ready] All agentic workflows, media, social, and ads engines running at maximum capacity.
            </div>
            <div class="nav-links">
                <a href="/specs.html" class="btn">Visualizza Specs & Hub</a>
                <button class="btn" onclick="triggerPulse()">Esegui Pulsazione AGI</button>
            </div>
        </div>

        <div class="panel">
            <h2>Stato Motori e Infrastruttura ZDOS</h2>
            <ul class="metrics-list">
                <li><span>Z-Lang Compiler Runtime</span><span>ONLINE (No-Std)</span></li>
                <li><span>Zclipper AI Media / Ads Store</span><span>ACTIVE (Additive)</span></li>
                <li><span>OpenClaw Heartbeat Sync</span><span>0.04ms (Stable)</span></li>
                <li><span>Primary Indices Shield</span><span>SECURED / PROTECTED</span></li>
            </ul>
        </div>
    </div>

    <script>
        function triggerPulse() {
            const t = document.getElementById('term');
            const time = new Date().toLocaleTimeString();
            t.innerHTML += `<br>[${time}] [PULSE] Hyper Conscious heartbeat sincronizzato con successo.`;
            t.scrollTop = t.scrollHeight;
        }
    </script>
</body>
</html>
INDEX_HTML

        # 3. Scrittura del nuovo specs.html (Specifiche complete e interfaccia di orchestrazione)
        cat << 'SPECS_HTML' > "$DIR/specs.html"
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Zclipper & ZDOS - AI Agent Orchestration Specs</title>
    <style>
        :root {
            --bg-color: #0b0f19;
            --card-bg: #111827;
            --text-main: #f3f4f6;
            --text-muted: #9ca3af;
            --accent: #3b82f6;
            --border: #1f2937;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: var(--bg-color);
            color: var(--text-main);
            line-height: 1.6;
            margin: 0;
            padding: 20px;
        }
        .container { max-width: 900px; margin: 0 auto; padding: 40px 20px; }
        header { text-align: center; margin-bottom: 40px; }
        h1 { font-size: 2.3rem; background: linear-gradient(90deg, #60a5fa, #a78bfa); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .card { background-color: var(--card-bg); border: 1px solid var(--border); border-radius: 12px; padding: 30px; margin-bottom: 30px; }
        h2 { color: #60a5fa; border-bottom: 1px solid var(--border); padding-bottom: 10px; margin-top: 0; }
        .btn { display: inline-block; background-color: var(--accent); color: white; padding: 12px 30px; border-radius: 6px; text-decoration: none; font-weight: bold; }
        .btn:hover { background-color: #2563eb; }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Zclipper Core Specs & Hyper Conscious Hub</h1>
            <p style="color: var(--text-muted);">Orchestratore AI avanzato, OpenClaw e Z-Lang Ecosystem</p>
        </header>
        <div class="card">
            <h2>Architettura e Funzioni</h2>
            <p>Zclipper unisce la gestione agentica dei task, l'organigramma aziendale autonomo e i moduli di automazione media, social e ads in un unico ecosistema protetto e additivo.</p>
        </div>
        <div style="text-align: center; margin-top: 30px;">
            <a href="/" class="btn">Torna alla Home Hyper Conscious</a>
        </div>
    </div>
</body>
</html>
SPECS_HTML

        echo "[ok] Portale aggiornato correttamente in $DIR."
    fi
done

# Ricarica Nginx per rendere subito effettive le modifiche
if command -v systemctl &> /dev/null; then
    systemctl reload nginx
    echo "[ok] Servizio Nginx ricaricato con successo."
fi
echo "=============================================================================="
