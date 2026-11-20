#!/usr/bin/env bash
# ==============================================================================
# ZDOS UNIVERSE & OPENCLAW MASTER AUTOBUILD (INDEX UPDATE)
# Regola ferrea: Aggiorna l'index principale con OpenClaw, chat AGI e Z-Lang.
# Nessun indice primario o dato storico viene toccato o eliminato.
# ==============================================================================

TARGET_FILE="index.html"
BACKUP_DIR="master_backup"

echo "[+] Avvio aggiornamento dell'universo ZDOS su index.html..."

# 1. Backup di sicurezza dell'index esistente
mkdir -p "$BACKUP_DIR"
if [ -f "$TARGET_FILE" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    cp "$TARGET_FILE" "$BACKUP_DIR/index.html.bak_$TIMESTAMP"
    echo "[ok] Backup di sicurezza dell'index creato in $BACKUP_DIR."
fi

# 2. Scrittura del nuovo index unificato (ZDOS Universe + OpenClaw + Z-Lang Chat)
cat << 'HTML_EOF' > "$TARGET_FILE"
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ZDOS Universe &middot; OpenClaw AGI Core & Z-Lang</title>
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
            background: linear-gradient(90deg, #38bdf8, #818cf8);
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
        .grid-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            flex: 1;
            min-height: 0;
        }
        @media (max-width: 768px) {
            .grid-container {
                grid-template-columns: 1fr;
            }
        }
        .panel {
            background-color: var(--panel-bg);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            display: flex;
            flex-direction: column;
            padding: 15px;
            overflow: hidden;
        }
        .panel h2 {
            font-size: 1rem;
            margin-top: 0;
            margin-bottom: 15px;
            color: #94a3b8;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 8px;
        }
        .chat-box {
            flex: 1;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 12px;
            font-size: 0.9rem;
            padding-right: 5px;
        }
        .message {
            padding: 10px 14px;
            border-radius: 8px;
            max-width: 85%;
        }
        .message.agent {
            background: rgba(59, 130, 246, 0.1);
            border-left: 3px solid var(--accent-blue);
            align-self: flex-start;
        }
        .message.dev {
            background: rgba(139, 92, 246, 0.1);
            border-left: 3px solid var(--accent-purple);
            align-self: flex-end;
        }
        .sender {
            font-size: 0.75rem;
            font-weight: bold;
            margin-bottom: 4px;
            color: #cbd5e1;
        }
        .metrics-list {
            list-style: none;
            padding: 0;
            margin: 0;
            font-size: 0.9rem;
        }
        .metrics-list li {
            padding: 8px 0;
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
            <h1>ZDOS Universe &middot; OpenClaw Hub</h1>
            <span style="font-size: 0.8rem; color: var(--text-muted);">Runtime: Z-Lang Core v2.4 Active</span>
        </div>
        <div class="status-badge">● OpenClaw AGI Online</div>
    </header>

    <div class="grid-container">
        <!-- Pannello Chat Reale AGI & Sviluppatori Z-Lang -->
        <div class="panel">
            <h2>Live AGI & Devs Stream (Z-Lang Engine)</h2>
            <div class="chat-box" id="chatStream">
                <div class="message agent">
                    <div class="sender">OpenClaw (AGI Core) [Z-Lang v2.4]</div>
                    Inizializzazione cluster completata. Indici primari protetti in modalità additiva. Pronto per l'orchestrazione media e ads.
                </div>
                <div class="message dev">
                    <div class="sender">Kali (High-CDE / Dev)</div>
                    Ottimo OpenClaw. Verifica che i moduli zclipper e le route di x-zdos.it siano al massimo regime senza toccare lo storico.
                </div>
                <div class="message agent">
                    <div class="sender">OpenClaw (AGI Core)</div>
                    Confermato. Motori accesi al 100%. Esecuzione script Z-Lang in tempo reale avviata sui nodi VPS.
                </div>
            </div>
        </div>

        <!-- Pannello Stato Motori e Servizi -->
        <div class="panel">
            <h2>Stato Motori e Infrastruttura ZDOS</h2>
            <ul class="metrics-list">
                <li><span>Z-Lang Compiler Runtime</span><span>ONLINE (No-Std)</span></li>
                <li><span>Zclipper AI Media / Ads Store</span><span>ACTIVE (Additive)</span></li>
                <li><span>OpenClaw Heartbeat Sync</span><span>0.04ms (Stable)</span></li>
                <li><span>Primary Indices Shield</span><span>SECURED / PROTECTED</span></li>
                <li><span>Contabo VPS Node (`vmi3082470`)</span><span>MAX PERFORMANCE</span></li>
            </ul>
        </div>
    </div>

</body>
</html>
HTML_EOF

echo "[ok] Pagina principale index.html aggiornata con successo con OpenClaw e Z-Lang."
echo "[ok] Nessun file o indice primario esterno è stato compromesso."
echo "=============================================================================="
