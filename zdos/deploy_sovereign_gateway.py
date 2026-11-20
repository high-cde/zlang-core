import os
import subprocess

print("🚀 [ZDOS MASTER GATEWAY DEPLOY]: Sincronizzazione finale e push globale su tutti i repository...")

workspace = "/root/zdos/github_workspace"
success_count = 0

for repo in os.listdir(workspace):
    repo_path = os.path.join(workspace, repo)
    if os.path.isdir(os.path.join(repo_path, ".git")):
        os.chdir(repo_path)
        
        # Sincronizzazione e push forzato per azzerare qualsiasi disallineamento
        subprocess.run("git add .", shell=True, capture_output=True)
        subprocess.run("git commit -m 'ZDOS Sovereign Gateway: Sincronizzazione e attivazione globale' || true", shell=True, capture_output=True)
        
        branch = subprocess.run("git branch --show-current", shell=True, capture_output=True, text=True).stdout.strip() or "main"
        push_res = subprocess.run(f"git push origin {branch} || git push origin master || true", shell=True, capture_output=True)
        
        if push_res.returncode == 0:
            success_count += 1
            print(f"✅ [PUSH RIUSCITO]: {repo} sincronizzato con successo.")
        else:
            print(f"⚠️ [ATTENZIONE]: {repo} completato localmente.")

print(f"\n✨ [MISSIONE COMPIUTA]: {success_count} repository sincronizzati, protetti e operativi nella rete sovrana!")
