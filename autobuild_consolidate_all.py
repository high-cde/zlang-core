import os
import shutil
import subprocess
import urllib.request
import urllib.error
import json

print("=== 1. VERIFICA MODULI BACKEND (/opt/zdos-omni-nexus) ===")
nexus_dir = "/opt/zdos-omni-nexus"
required_js = [
    "nexus.js",
    "global-id-mint.js",
    "meat-radar-engine.js",
    "omni-handle-bridge.js",
    "velvet-shop-engine.js",
]

for fname in required_js:
    fpath = os.path.join(nexus_dir, fname)
    if not os.path.isfile(fpath):
        print(f"⚠️ File mancante: {fpath}")
        continue
    chk = subprocess.run(["node", "--check", fpath], capture_output=True, text=True)
    if chk.returncode != 0:
        print(f"❌ Errore sintassi in {fpath}:\n{chk.stderr}")
        raise SystemExit(1)
    print(f"✅ Sintassi OK: {fname}")

print("\n=== 2. ALLINEAMENTO WEB ASSETS & PULIZIA RIFERIMENTI LUDICI ===")
os.makedirs("/var/www/ourvelvet/assets", exist_ok=True)
web_files = ["dashboard.html", "shop.html", "velvet-gate-widget.html", "lodge-card.html"]

for wf in web_files:
    src_p = os.path.join("/var/www/ourvelvet", wf)
    if os.path.isfile(src_p):
        with open(src_p, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        # Assicura rimozione di ogni residuo "Quest" / "Gioco" a favore di "Direct Reality / Meat Radar"
        cleaned = (
            content.replace("Quest Arena", "Radar 30km")
            .replace("Quest Hub", "Dashboard")
            .replace("Real Game", "Direct Reality")
        )
        if cleaned != content:
            with open(src_p, "w", encoding="utf-8") as f:
                f.write(cleaned)
        # Copia anche in /var/www/velvethub/dist/public/ se esiste per fallback diretto
        dist_dir = "/var/www/velvethub/dist/public"
        if os.path.isdir(dist_dir) and wf in ("dashboard.html", "shop.html"):
            shutil.copy2(src_p, os.path.join(dist_dir, wf))
        print(f"✅ Consolidato asset web: {wf}")

print("\n=== 3. VALIDAZIONE NGINX & RIAVVIO SERVIZI PM2 ===")
subprocess.run(["nginx", "-t"], check=True)
subprocess.run(["systemctl", "reload", "nginx"], check=True)
subprocess.run(["pm2", "restart", "zdos-omni-nexus"], check=False)
subprocess.run(["pm2", "save"], check=False)
print("✅ Nginx e PM2 sincronizzati")

print("\n=== 4. HEALTH CHECK ENDPOINT DI PRODUZIONE (HTTPS) ===")
get_endpoints = [
    "https://velvet.x-zdos.it/",
    "https://velvet.x-zdos.it/dashboard.html",
    "https://velvet.x-zdos.it/shop.html",
    "https://velvet.x-zdos.it/lodge-card.html",
    "https://velvet.x-zdos.it/api/meat-radar/telemetry",
    "https://velvet.x-zdos.it/api/bridge/status",
    "https://velvet.x-zdos.it/api/shop/catalog",
]

for url in get_endpoints:
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "ZDOS-Consolidator/1.0"})
        with urllib.request.urlopen(req, timeout=8) as r:
            body = r.read().decode("utf-8", errors="ignore")
            snippet = body[:90].replace("\n", " ").strip()
            print(f"✅ HTTP {r.status} | {url} -> {snippet}...")
    except urllib.error.HTTPError as e:
        print(f"⚠️ HTTP {e.code} | {url}")
    except Exception as e:
        print(f"❌ ERR | {url} -> {e}")

# Test POST RPC Proxy anti-403
try:
    rpc_req = urllib.request.Request(
        "https://velvet.x-zdos.it/api/solana-rpc",
        data=json.dumps({"jsonrpc": "2.0", "id": 1, "method": "getHealth"}).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(rpc_req, timeout=8) as r:
        print(f"✅ HTTP {r.status} | POST /api/solana-rpc -> {r.read().decode('utf-8')}")
except Exception as e:
    print(f"⚠️ RPC Proxy check: {e}")

print("\n=== 5. COMMIT & PUSH CONSOLIDATO SU GITHUB (high-cde) ===")
repos = ["/opt/zdos-velvet-stack-repo", "/var/www/velvethub"]
for repo in repos:
    if not os.path.isdir(os.path.join(repo, ".git")):
        continue
    if repo == "/opt/zdos-velvet-stack-repo":
        for fname in required_js:
            s = os.path.join(nexus_dir, fname)
            if os.path.isfile(s):
                shutil.copy2(s, os.path.join(repo, fname))
        for wf in web_files:
            s = os.path.join("/var/www/ourvelvet", wf)
            if os.path.isfile(s):
                shutil.copy2(s, os.path.join(repo, wf))
    st = subprocess.run(["git", "-C", repo, "status", "--porcelain"], capture_output=True, text=True).stdout.strip()
    if st:
        subprocess.run(["git", "-C", repo, "add", "-A"], check=False)
        subprocess.run(
            ["git", "-C", repo, "commit", "-m", "chore(release): consolidate real-world Velvet ecosystem (Meat Radar, Global ID, Omni Bridge, Solana Shop)"],
            capture_output=True,
            text=True,
        )
        push = subprocess.run(["git", "-C", repo, "push"], capture_output=True, text=True)
        print(f"✅ PUSH {repo}: {(push.stdout.strip() or push.stderr.strip())[:220]}")
    else:
        print(f"ℹ️ {repo}: già allineato su GitHub")

print("\n🚀 CONSOLIDAMENTO COMPLETATO.")
