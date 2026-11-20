#!/usr/bin/env bash
# ==============================================================================
# ZDOS & ZCLIPPER SUPREME AGI AUTOBUILD (FRONTEND & BACKEND FULL SPECS)
# Regola ferrea: Zero cancellazioni. Protezione totale indici e backup attivi.
# ==============================================================================

TARGET_DIRS=("/var/www/x-zdos" "/var/www/html")

for DIR in "${TARGET_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        echo "[+] Applicazione Super Comando in: $DIR"

        # 1. Backup di sicurezza preventivo
        mkdir -p "$DIR/master_backup"
        [ -f "$DIR/index.html" ] && cp "$DIR/index.html" "$DIR/master_backup/index.html.bak_$(date +%Y%m%d_%H%M%S)"
        [ -f "$DIR/specs.html" ] && cp "$DIR/specs.html" "$DIR/master_backup/specs.html.bak_$(date +%Y%m%d_%H%M%S)"

        # 2. Generazione della pagina specs.html con tutte le specifiche AGI Supreme e Requisiti
        cat << 'SPECS_SUPREME' > "$DIR/specs.html"
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Zclipper & ZDOS - Supreme AGI Command Center & Specs</title>
    <style>
        :root {
            --bg: #07090e;
            --panel: #0d131f;
            --border: #1e293b;
            --text: #f1f5f9;
            --muted: #64748b;
            --green: #10b981;
            --blue: #3b82f6;
            --purple: #8b5cf6;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: var(--bg);
            color: var(--text);
            margin: 0;
            padding: 20px;
            line-height: 1.6;
        }
        .container { max-width: 1000px; margin: 0 auto; }
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border);
            padding-bottom: 15px;
            margin-bottom: 25px;
        }
        h1 {
            font-size: 1.8rem;
            margin: 0;
            background: linear-gradient(90deg, #38bdf8, #a78bfa);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .badge {
            background: rgba(16, 185, 129, 0.1);
            color: var(--green);
            border: 1px solid rgba(16, 185, 129, 0.3);
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: bold;
        }
        .card {
            background-color: var(--panel);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }
        h2 { font-size: 1.2rem; color: #60a5fa; border-bottom: 1px solid var(--border); padding-bottom: 8px; margin-top: 0; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 15px; }
        .pillar { background: rgba(255,255,255,0.02); border: 1px solid var(--border); padding: 15px; border-radius: 8px; }
        .pillar h3 { margin-top: 0; color: #a78bfa; font-size: 1rem; }
        ul { padding-left: 18px; margin: 0; color: var(--muted); font-size: 0.9rem; }
        li { margin-bottom: 6px; }
        .terminal {
            background: #030508;
            border: 1px solid var(--border);
            border-radius: 6px;
            padding: 12px;
            font-family: monospace;
            font-size: 0.85rem;
            color: #34d399;
            height: 120px;
            overflow-y: auto;
            margin-top: 15px;
        }
        .btn {
            display: inline-block;
            background: var(--blue);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            font-weight: bold;
            text-decoration: none;
            cursor: pointer;
            margin-top: 10px;
        }
        .btn:hover { background: #2563eb; }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div>
                <h1>⚡ Zclipper & ZDOS &middot; Supreme AGI Hub</h1>
                <span style="font-size: 0.85rem; color: var(--muted);">Orchestrazione Agentica Avanzata (Paperclip Fork)</span>
            </div>
            <div class="badge">● ENGINES MAX</div>
        </header>

        <div class="card">
            <h2>I Quattro Pilastri del Sistema</h2>
            <div class="grid">
                <div class="pillar">
                    <h3>1. Task Manager Agentico</h3>
                    <p style="font-size:0.85rem; color:var(--muted);">Gestione ticket, approvazioni, code atomiche e verifiche tramite diff, screenshot e test.</p>
                </div>
                <div class="pillar">
                    <h3>2. Organigramma AI</h3>
                    <p style="font-size:0.85rem; color:var(--muted);">Ruoli misti umani e bot, confini aziendali, deleghe strutturate e segreti protetti.</p>
                </div>
                <div class="pillar">
                    <h3>3. Training ed Evals</h3>
                    <p style="font-size:0.85rem; color:var(--muted);">Skill Studio condiviso, versionamento competenze e cicli di apprendimento attivo.</p>
                </div>
                <div class="pillar">
                    <h3>4. Agentic OS</h3>
                    <p style="font-size:0.85rem; color:var(--muted);">Runtime multi-provider (Claude, Codex, OpenClaw, Pi), sandboxing e controlli di costo.</p>
                </div>
            </div>
        </div>

        <div class="card">
            <h2>Requisiti Tecnici e Necessità di Sistema</h2>
            <ul>
                <li><strong>Node.js:</strong> Richiesto Node.js 24.11 o superiore[span_0](start_span)[span_0](end_span).</li>
                <li><strong>pnpm:</strong> Richiesto pnpm 9.15 o superiore per la gestione del workspace[span_1](start_span)[span_1](end_span).</li>
                <li><strong>Python 3 & CLI:</strong> Necessario per l'autenticazione locale e l'accesso in abbonamento (Claude / Codex)[span_2](start_span)[span_2](end_span).</li>
                <li><strong>Rust Toolchain:</strong> Indispensabile per la compilazione nativa del Paperclip/Zclipper Runner self-hosted[span_3](start_span)[span_3](end_span).</li>
                <li><strong>Database & Storage:</strong> PostgreSQL integrato per lo sviluppo, storage crittografato locale per file e credenziali.</li>
            </ul>
        </div>

        <div class="card">
            <h2>Telemetria e Controllo Live</h2>
            <div class="terminal" id="term">
                [supreme-init] ZDOS Supreme AGI core online.<br>
                [z-lang] JIT runtime attivo in modalità additiva.<br>
                [ready] Tutti i motori media, social, ads e heartbeat OpenClaw operativi.
            </div>
            <a href="/" class="btn">Torna alla Home Hyper Conscious</a>
        </div>
    </div>
</body>
</html>
SPECS_SUPREME

        echo "[ok] Pagina specs.html aggiornata con successo in $DIR."
    fi
done

# Riavvio Nginx
if command -v systemctl &> /dev/null; then
    systemctl reload nginx
    echo "[ok] Servizio Nginx ricaricato con successo."
fi
echo "=============================================================================="
