import os
import re
import shutil
import subprocess
import urllib.request

CONF_PATH = "/etc/nginx/sites-available/ourvelvet"
BACKUP_PATH = "/root/ourvelvet.nginx.bak"

if not os.path.exists(CONF_PATH):
    raise SystemExit(f"File non trovato: {CONF_PATH}")

shutil.copy2(CONF_PATH, BACKUP_PATH)
print(f"✅ Backup creato in {BACKUP_PATH}")

with open(CONF_PATH, "r", encoding="utf-8") as f:
    content = f.read()

lodge_locations = """
    location = /lodge-card.html {
        alias /var/www/ourvelvet/lodge-card.html;
        default_type text/html;
    }

    location /assets/ {
        alias /var/www/ourvelvet/assets/;
    }
"""

if "location = /lodge-card.html" not in content:
    # Inserisce dentro il blocco server che contiene ssl_certificate /etc/letsencrypt/live/velvet.x-zdos.it/fullchain.pem
    target_marker = "ssl_certificate /etc/letsencrypt/live/velvet.x-zdos.it/fullchain.pem;"
    idx = content.find(target_marker)
    if idx != -1:
        # Cerca la prima 'location ' dopo il certificato del blocco SSL di velvet.x-zdos.it
        loc_match = re.search(r"\n(\s*)location\s+", content[idx:])
        if loc_match:
            insert_pos = idx + loc_match.start()
            content = content[:insert_pos] + "\n" + lodge_locations + content[insert_pos:]
        else:
            # Fallback: inserisce prima della chiusura dell'ultimo '}' del file
            last_brace = content.rfind("}")
            content = content[:last_brace] + lodge_locations + "\n" + content[last_brace:]
    else:
        last_brace = content.rfind("}")
        content = content[:last_brace] + lodge_locations + "\n" + content[last_brace:]

    with open(CONF_PATH, "w", encoding="utf-8") as f:
        f.write(content)
    print("✅ Direttive lodge-card.html e /assets/ aggiunte a /etc/nginx/sites-available/ourvelvet")
else:
    print("ℹ️ Direttive lodge-card.html già presenti")

subprocess.run(["nginx", "-t"], check=True)
subprocess.run(["systemctl", "reload", "nginx"], check=True)

for url in ["https://velvet.x-zdos.it/lodge-card.html", "https://velvet.x-zdos.it/assets/card-mistress-gif.gif"]:
    try:
        req = urllib.request.Request(url, method="HEAD")
        with urllib.request.urlopen(req, timeout=8) as resp:
            print(f"✅ {url} -> HTTP {resp.status}")
    except Exception as exc:
        print(f"⚠️ {url} -> {exc}")
