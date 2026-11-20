import os
import shutil
import subprocess
import urllib.request

CONF = "/etc/nginx/sites-available/velvethub"
BAK = "/root/velvethub.nginx.bak"

shutil.copy2(CONF, BAK)
print("✅ Backup salvato in", BAK)

with open(CONF, "r", encoding="utf-8") as f:
    src = f.read()

add_block = """    location = /lodge-card.html {
        alias /var/www/ourvelvet/lodge-card.html;
        default_type text/html;
    }

    location /assets/ {
        alias /var/www/ourvelvet/assets/;
    }

"""

target = "    location / {"
if "location = /lodge-card.html" not in src:
    if target not in src:
        raise RuntimeError("Blocco 'location / {' non trovato in velvethub")
    src = src.replace(target, add_block + target, 1)
    with open(CONF, "w", encoding="utf-8") as f:
        f.write(src)
    print("✅ Aggiunte location = /lodge-card.html e location /assets/ in", CONF)
else:
    print("ℹ️ Direttive già presenti in", CONF)

subprocess.run(["nginx", "-t"], check=True)
subprocess.run(["systemctl", "reload", "nginx"], check=True)
print("✅ Nginx testato e ricaricato con successo!")

for url in ["https://velvet.x-zdos.it/lodge-card.html", "https://velvet.x-zdos.it/assets/card-mistress-gif.gif"]:
    try:
        req = urllib.request.Request(url, method="HEAD")
        with urllib.request.urlopen(req, timeout=8) as resp:
            print(f"✅ {url} -> HTTP {resp.status}")
    except Exception as exc:
        print(f"⚠️ {url} -> {exc}")
