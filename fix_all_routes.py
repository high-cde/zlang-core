import os
import shutil
import subprocess
import urllib.request

# 1. Configurazione unificata per x-zdos.it e www.x-zdos.it
src_nuovo = "/etc/nginx/sites-available/x-zdos-it-nuovo"
xzdos_conf = "/etc/nginx/sites-available/x-zdos-unified"

with open(src_nuovo, "r", encoding="utf-8") as f:
    xzdos_txt = f.read()

zdesk_block = """    # ZDESK reverse proxy (attivo su 127.0.0.1:8787)
    location = /zdesk { return 301 /zdesk/; }
    location /zdesk/ {
        proxy_pass http://127.0.0.1:8787/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Prefix /zdesk;
        proxy_read_timeout 120s;
    }

    location / {"""

if "/zdesk/" not in xzdos_txt and "    location / {" in xzdos_txt:
    xzdos_txt = xzdos_txt.replace("    location / {", zdesk_block, 1)

with open(xzdos_conf, "w", encoding="utf-8") as f:
    f.write(xzdos_txt)
print("✅ Scritta configurazione unificata:", xzdos_conf)

# 2. Aggiornamento velvethub: porta 8000 (uvicorn) al posto della 3000 spenta
velvet_conf = "/etc/nginx/sites-available/velvethub"
shutil.copy2(velvet_conf, "/root/velvethub.before_8000.bak")
with open(velvet_conf, "r", encoding="utf-8") as f:
    v_txt = f.read()

v_txt = v_txt.replace("http://127.0.0.1:3000", "http://127.0.0.1:8000")
with open(velvet_conf, "w", encoding="utf-8") as f:
    f.write(v_txt)
print("✅ Aggiornato upstream di velvethub a http://127.0.0.1:8000")

# 3. Attivazione symlink puliti in sites-enabled
enabled = "/etc/nginx/sites-enabled"
for name, target in [
    ("velvethub", velvet_conf),
    ("x-zdos-unified", xzdos_conf),
]:
    link_path = os.path.join(enabled, name)
    if os.path.lexists(link_path):
        os.unlink(link_path)
    os.symlink(target, link_path)
    print(f"✅ Attivato {link_path} -> {target}")

subprocess.run(["nginx", "-t"], check=True)
subprocess.run(["systemctl", "reload", "nginx"], check=True)
print("✅ nginx -t e reload completati!")

test_urls = [
    "https://velvet.x-zdos.it/lodge-card.html",
    "https://velvet.x-zdos.it/",
    "https://x-zdos.it/",
    "https://x-zdos.it/ide/",
    "https://x-zdos.it/xcloud/",
]
for u in test_urls:
    try:
        req = urllib.request.Request(u, method="GET")
        with urllib.request.urlopen(req, timeout=8) as r:
            print(f"✅ {u} -> HTTP {r.status}")
    except urllib.error.HTTPError as he:
        print(f"ℹ️ {u} -> HTTP {he.code}")
    except Exception as e:
        print(f"⚠️ {u} -> {e}")
