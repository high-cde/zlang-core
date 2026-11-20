#!/usr/bin/env bash
# ==============================================================================
# RESTORE PRIMARY HOME (ZDOS OFFICIAL PORTAL)
# Ripristina la home principale originale e pulita su x-zdos.it
# ==============================================================================

TARGET_DIRS=("/var/www/x-zdos" "/var/www/html")

for DIR in "${TARGET_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        echo "[+] Ripristino home primaria in: $DIR"

        # Creazione della home primaria ufficiale pulita e stabile
        cat << 'PRIMARY_HOME' > "$DIR/index.html"
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ZDOS Sovereign Core &middot; Home Primaria</title>
    <style>
        :root {
            --bg-base: #07090e;
            --surface: #0d131f;
            --border: #1e293b;
            --text-main: #f1f5f9;
            --text-muted: #94a3b8;
            --accent-blue: #3b82f6;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: var(--bg-base);
            color: var(--text-main);
            margin: 0;
            padding: 40px 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            box-sizing: border-box;
        }
        .card {
            background-color: var(--surface);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 30px;
            max-width: 500px;
            width: 100%;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        }
        h1 {
            font-size: 1.5rem;
            margin-top: 0;
            background: linear-gradient(90deg, #38bdf8, #818cf8);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        p {
            color: var(--text-muted);
            font-size: 0.95rem;
            line-height: 1.5;
        }
        .btn {
            display: inline-block;
            background-color: var(--accent-blue);
            color: white;
            padding: 10px 20px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: bold;
            margin-top: 15px;
            font-size: 0.9rem;
        }
        .btn:hover { background-color: #2563eb; }
    </style>
</head>
<body>
    <div class="card">
        <h1>ZDOS Sovereign Ecosystem</h1>
        <p>Benvenuto nel portale primario di ZDOS. La home di base è attiva, protetta e sincronizzata con i server Contabo.</p>
        <a href="/specs.html" class="btn">Accedi a Zclipper & Specs Hub</a>
    </div>
</body>
</html>
PRIMARY_HOME

        echo "[ok] Home primaria ripristinata in $DIR."
    fi
done

# Riavvio Nginx
if command -v systemctl &> /dev/null; then
    systemctl reload nginx
    echo "[ok] Nginx ricaricato."
fi
echo "=============================================================================="
