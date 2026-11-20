import shutil
import subprocess
import urllib.request

CONF = "/etc/nginx/sites-available/velvethub"
BAK = "/root/velvethub.pre_lodge.bak"

shutil.copy2(CONF, BAK)

with open(CONF, "r", encoding="utf-8") as f:
    src = f.read()

lodge_locations = """    location = /lodge-card.html {
        alias /var/www/ourvelvet/lodge-card.html;
        default_type text/html;
    }

    location /assets/ {
        alias /var/www/ourvelvet/assets/;
    }

"""

marker = "    location / {"
if "location = /lodge-card.html" not in src:
    if marker not in src:
        raise RuntimeError("Marker 'location / {' non trovato")
    src = src.replace(marker, lodge_locations + marker, 1)
    with open(CONF, "w", encoding="utf-8") as f:
        f.write(src)

subprocess.run(["nginx", "-t"], check=True)
subprocess.run(["systemctl", "reload", "nginx"], check=True)
print("✅ Nginx ricaricato con le route per /lodge-card.html e /assets/")

for url in ["https://velvet.x-zdos.it/lodge-card.html", "https://velvet.x-zdos.it/assets/card-mistress-gif.gif"]:
    try:
        req = urllib.request.Request(url, method="HEAD")
        with urllib.request.urlopen(req, timeout=8) as resp:
            print(f"✅ {url} -> HTTP {resp.status}")
    except Exception as exc:
        print(f"⚠️ {url} -> {exc}")
