import os
import shutil
import subprocess
import urllib.request

CONF_PATH = "/etc/nginx/sites-available/ourvelvet"
BACKUP_PATH = "/root/ourvelvet.nginx.bak"

if os.path.exists(BACKUP_PATH):
    shutil.copy2(BACKUP_PATH, CONF_PATH)

with open(CONF_PATH, "r", encoding="utf-8") as f:
    text = f.read()

lodge_block = """
    location = /lodge-card.html {
        alias /var/www/ourvelvet/lodge-card.html;
        default_type text/html;
    }

    location /assets/ {
        alias /var/www/ourvelvet/assets/;
    }
"""

def add_locations(src: str) -> str:
    if "location = /lodge-card.html" in src:
        return src
    cert_pos = src.find("/etc/letsencrypt/live/velvet.x-zdos.it/fullchain.pem")
    if cert_pos == -1:
        cert_pos = src.find("ssl_certificate")
    server_start = src.rfind("server", 0, cert_pos)
    brace_open = src.find("{", server_start)
    if brace_open == -1:
        raise RuntimeError("Blocco server non trovato")
    depth = 0
    for i in range(brace_open, len(src)):
        if src[i] == "{":
            depth += 1
        elif src[i] == "}":
            depth -= 1
            if depth == 0:
                return src[:i] + lodge_block + "\n" + src[i:]
    raise RuntimeError("Graffe non bilanciate")

with open(CONF_PATH, "w", encoding="utf-8") as f:
    f.write(add_locations(text))

subprocess.run(["nginx", "-t"], check=True)
subprocess.run(["systemctl", "reload", "nginx"], check=True)
print("NGINX_OK")

for url in ["https://velvet.x-zdos.it/lodge-card.html", "https://velvet.x-zdos.it/assets/card-mistress-gif.gif"]:
    try:
        req = urllib.request.Request(url, method="HEAD")
        with urllib.request.urlopen(req, timeout=8) as resp:
            print(url, "->", resp.status)
    except Exception as exc:
        print(url, "->", exc)
