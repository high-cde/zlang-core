import os
import sqlite3
import subprocess

print("==================================================")
print("🔍 [ZDOS DIAGNOSTICA SOVRANA]: Analisi integrità in corso...")
print("==================================================")

# 1. Controllo Servizi Systemd
services = ["zdos-faucet", "zdos-miner", "xcloud-backend", "nginx"]
for s in services:
    res = subprocess.run(f"systemctl is-active {s}", shell=True, capture_output=True, text=True)
    status = res.stdout.strip()
    icon = "✅" if status == "active" else "❌"
    print(f"{icon} Servizio {s}: {status.upper()}")

print("--------------------------------------------------")

# 2. Controllo Database SQLite xCLOUD
db_path = '/root/zdos/xcloud_enterprise.db'
if os.path.exists(db_path):
    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    c.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = [row[0] for row in c.fetchall()]
    conn.close()
    print(f"✅ Database SQLite xCLOUD attivo. Tabelle censite: {', '.join(tables)}")
else:
    print("❌ Database xCLOUD non trovato.")

print("--------------------------------------------------")

# 3. Controllo Workspace GitHub bonificato
workspace = "/root/zdos/github_workspace"
if os.path.exists(workspace):
    repos = [r for r in os.listdir(workspace) if os.path.isdir(os.path.join(workspace, r, ".git"))]
    print(f"✅ Workspace GitHub sincronizzato. Repository sovrani bonificati: {len(repos)}/20")
else:
    print("⚠️ Workspace GitHub locale non inizializzato.")

print("--------------------------------------------------")

# 4. Test API Gateway Multi-IA & Faucet locale
print("📡 Verifica risposte API locali...")
api_test = subprocess.run("curl -s http://127.0.0.1:8090/api/stats", shell=True, capture_output=True, text=True)
if api_test.returncode == 0 and "active_sync" in api_test.stdout:
    print("✅ Gateway xCLOUD & SQLite: ATTIVO E RISpondente")
else:
    print("❌ Anomalia nella risposta delle API xCLOUD.")

print("==================================================")
print("✨ Diagnosi completata: L'infrastruttura è sovrana ZDOS.")
print("==================================================")
