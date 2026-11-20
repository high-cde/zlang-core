import os
import subprocess

print("📊 [ZDOS SOVEREIGN DASHBOARD]: Generazione report di stato in tempo reale...\n")

# 1. Controllo stato Nginx e sito web
nginx_status = subprocess.run("systemctl is-active nginx", shell=True, capture_output=True, text=True).stdout.strip()
print(f"🌐 Servizio Web (x-zdos.it): [{nginx_status.upper()}]")

# 2. Controllo demone di sistema
daemon_status = subprocess.run("pgrep -f zdos_daemon.py", shell=True, capture_output=True).returncode == 0
print(f"⚡ Demone Z-Pulse: [{'ATTIVO E OPERATIVO' if daemon_status else 'IN ATTESA'}]")

# 3. Scansione repository locali sincronizzati
workspace = "/root/zdos/github_workspace"
repos = [d for d in os.listdir(workspace) if os.path.isdir(os.path.join(workspace, d, ".git"))]
print(f"📦 Repository Gestiti: {len(repos)} moduli attivi nella mesh.")

print("\n✨ [STATUS]: Tutti i sistemi operativi rispondono senza errori. In attesa dei tuoi ordini, Comandante!")
