import os
import shutil
import subprocess

BAK = "/root/velvethub.nginx.bak"
AVAIL_VELVETHUB = "/etc/nginx/sites-available/velvethub"
ENABLED_DIR = "/etc/nginx/sites-enabled"
TARGET_LINK = os.path.join(ENABLED_DIR, "velvethub")

if os.path.exists(BAK) and os.path.getsize(BAK) > 0:
    shutil.copy2(BAK, AVAIL_VELVETHUB)
    print("✅ Ripristinato /etc/nginx/sites-available/velvethub dal backup valido")

# Controlla eventuali file a 0 byte in sites-enabled e li sposta in /root/nginx_zero_bytes_bak/
zero_bak_dir = "/root/nginx_zero_bytes_bak"
os.makedirs(zero_bak_dir, exist_ok=True)
for fname in os.listdir(ENABLED_DIR):
    fpath = os.path.join(ENABLED_DIR, fname)
    # Controlla dimensione reale (seguendo symlink se possibile, o del file stesso)
    try:
        sz = os.stat(fpath, follow_symlinks=True).st_size
    except OSError:
        sz = 0
    if sz == 0 and os.path.isfile(fpath):
        shutil.move(fpath, os.path.join(zero_bak_dir, fname))
        print(f"🧹 Spostato file vuoto (0B) fuori da sites-enabled: {fname}")

# Assicura il symlink attivo per velvethub in sites-enabled
if os.path.lexists(TARGET_LINK):
    os.unlink(TARGET_LINK)
os.symlink(AVAIL_VELVETHUB, TARGET_LINK)
print("✅ Attivato symlink /etc/nginx/sites-enabled/velvethub -> /etc/nginx/sites-available/velvethub")

subprocess.run(["nginx", "-t"], check=True)
subprocess.run(["systemctl", "reload", "nginx"], check=True)
print("✅ nginx -t e reload completati con successo!")
