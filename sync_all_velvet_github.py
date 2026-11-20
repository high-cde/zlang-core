import os
import shutil
import subprocess

print("=== 1. POSIZIONAMENTO card-mistress-gif.gif ===")
gif_candidates = [
    "/root/card-mistress-gif.gif",
    "/tmp/card-mistress-gif.gif",
    "/var/www/ourvelvet/card-mistress-gif.gif",
    "/var/www/ourvelvet/assets/card-mistress-gif.gif",
]
src_gif = next((p for p in gif_candidates if os.path.isfile(p) and os.path.getsize(p) > 0), None)
os.makedirs("/var/www/ourvelvet/assets", exist_ok=True)

if src_gif:
    dst_web = "/var/www/ourvelvet/assets/card-mistress-gif.gif"
    if os.path.abspath(src_gif) != os.path.abspath(dst_web):
        shutil.copy2(src_gif, dst_web)
    subprocess.run(["chown", "-R", "www-data:www-data", "/var/www/ourvelvet/assets"], check=False)
    os.chmod(dst_web, 0o644)
    if os.path.isdir("/opt/zdos-velvet-stack-repo"):
        os.makedirs("/opt/zdos-velvet-stack-repo/assets", exist_ok=True)
        shutil.copy2(dst_web, "/opt/zdos-velvet-stack-repo/assets/card-mistress-gif.gif")
    print(f"✅ GIF posizionata ({os.path.getsize(dst_web)} byte): {dst_web}")
else:
    print("⚠️ GIF non ancora trovata in /root o /tmp (saltata senza bloccare il resto).")

print("\n=== 2. MIGRAZIONE AUTH BAILEYS & RIAVVIO OMNI-NEXUS ===")
incoming = "/tmp/baileys_auth_incoming"
target_auth = "/opt/zdos-omni-nexus/auth_info_baileys"
os.makedirs(target_auth, exist_ok=True)

if os.path.isdir(incoming) and os.listdir(incoming):
    for item in os.listdir(incoming):
        s = os.path.join(incoming, item)
        d = os.path.join(target_auth, item)
        if os.path.isdir(s):
            shutil.copytree(s, d, dirs_exist_ok=True)
        else:
            shutil.copy2(s, d)
    shutil.rmtree(incoming, ignore_errors=True)
    subprocess.run(["chmod", "-R", "700", target_auth], check=False)
    print(f"✅ Sessione Baileys importata in {target_auth}")
else:
    print(f"ℹ️ Nessuna nuova cartella in {incoming}; file attuali in {target_auth}: {len(os.listdir(target_auth))}")

# Protezione .gitignore per non caricare mai credenziali auth su GitHub
nexus_gitignore = "/opt/zdos-omni-nexus/.gitignore"
if os.path.isdir("/opt/zdos-omni-nexus"):
    existing_gi = ""
    if os.path.isfile(nexus_gitignore):
        with open(nexus_gitignore, "r", encoding="utf-8") as f:
            existing_gi = f.read()
    if "auth_info_baileys" not in existing_gi:
        with open(nexus_gitignore, "a", encoding="utf-8") as f:
            f.write("\nauth_info_baileys/\nauth/\n*.session\n")
        print("🔒 Aggiunto auth_info_baileys/ al .gitignore di zdos-omni-nexus")

subprocess.run(["pm2", "restart", "zdos-omni-nexus"], check=False)
subprocess.run(["pm2", "save"], check=False)

print("\n=== 3. SYNC FILE & PUSH SU GITHUB (high-cde) ===")
if os.path.isfile("/var/www/ourvelvet/lodge-card.html") and os.path.isdir("/opt/zdos-velvet-stack-repo"):
    shutil.copy2("/var/www/ourvelvet/lodge-card.html", "/opt/zdos-velvet-stack-repo/lodge-card.html")

repos = [
    "/opt/zdos-velvet-stack-repo",
    "/opt/zdos-omni-nexus",
    "/opt/ourvelvet",
    "/var/www/velvethub",
    "/var/www/zswap",
    "/var/www/ourvelvet",
    "/root/ZDOS",
]

for repo in repos:
    if not os.path.isdir(os.path.join(repo, ".git")):
        continue
    print(f"\n--- Repo: {repo} ---")
    rem = subprocess.run(["git", "-C", repo, "remote", "-v"], capture_output=True, text=True).stdout.strip()
    print(rem or "(nessun remote)")
    st = subprocess.run(["git", "-C", repo, "status", "--porcelain"], capture_output=True, text=True).stdout.strip()
    if st:
        subprocess.run(["git", "-C", repo, "add", "-A"], check=False)
        c = subprocess.run(
            ["git", "-C", repo, "commit", "-m", "chore(velvet): sync lodge-card, assets, nginx routes and omni-nexus"],
            capture_output=True,
            text=True,
        )
        print(c.stdout.strip() or c.stderr.strip())
        p = subprocess.run(["git", "-C", repo, "push"], capture_output=True, text=True)
        print(p.stdout.strip() or p.stderr.strip())
    else:
        print("✅ Già sincronizzato (nessuna modifica locale).")

print("\n=== 4. VERIFICA FINALE ENDPOINT & LOG NEXUS ===")
subprocess.run(["curl", "-sI", "https://velvet.x-zdos.it/assets/card-mistress-gif.gif"], check=False)
subprocess.run(["pm2", "logs", "zdos-omni-nexus", "--lines", "12", "--nostream"], check=False)
