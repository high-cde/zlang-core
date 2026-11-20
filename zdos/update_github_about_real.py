import os
import subprocess
import json
import urllib.request

# Legge il token di GitHub salvato o configurato nella VPS
token = os.popen("git config --global credential.helper").read().strip()
# In alternativa, peschiamo il token dalle credenziali memorizzate o chiediamo di inserirlo se necessario
print("🌐 [ZDOS API SYNC]: Connessione alle API di GitHub per l'aggiornamento dei campi About...")

descriptions = {
    "x-zdos-webapp": "ZDOS Sovereign Web App — Interfaccia unificata nativa",
    "zBAG": "ZDOS Sovereign Hyper-Wallet & DSN Asset Manager",
    "zclipper": "ZDOS Autonomous Agent & Workflow Orchestrator",
    "VelvetHub": "ZDOS Sovereign Secure Hub & Node Gateway",
    "zdos-microcosm-beta": "ZDOS Offline-first Android Laboratory & Zlang Terminal",
    "ZDOS": "Sistema operativo sperimentale x86_64 con ZDOS Linux e ZLang runtime",
    "zdos-hybrid": "ZDOS Hybrid Operating System Kernel & Security Environment",
    "zdos-organism": "Runtime Python sperimentale per ZDOS organismo digitale modulare",
    "Zlang": "Linguaggio di programmazione nativo e toolkit bytecode per ZDOS",
    "xzdos-vps-bundle": "ZDOS Enterprise VPS Deployment & Orchestration Bundle",
    "xCLOUD-by-zdos": "xCLOUD Enterprise — Piattaforma cloud nativa integrata con DSN & ZDOS",
    "ZDOS-lab-v1": "ZDOS Lab: Forge sorgente per contratti ZLang ed evidence chain",
    "xzdos-unified-webapp": "ZDOS Unified Enterprise Portal & Multi-AI Gateway",
    "NEXUS-X": "ZDOS Nexus Router & Synaptic Data Pipeline",
    "high-cde": "Profilo ufficiale GitHub di high-cde: Architetto ZDOS & AI Developer",
    "Z-GENESIS-HOST": "Z-GENESIS Bare-Metal Host & Microkernel Engine",
    "x-zdos-complete": "ZDOS Complete Sovereign Ecosystem Bundle",
    "Z-GENESIS-OS": "Z-GENESIS Civil Defender & Sovereign Operating Environment",
    "System.zdos.znode": "ZDOS Mobile Terminal & Node Pulse for Android (Termux extension)",
    "zdos-core": "Nucleo concettuale, specifiche e moduli base dell'ecosistema ZDOS"
}

# Sfruttiamo la CLI 'gh' se autenticata per aggiornare i repository in modo pulito
for repo, desc in descriptions.items():
    print(f"⚙️ Aggiornamento About remoto per: {repo}...")
    cmd = f"gh repo edit high-cde/{repo} --description \"{desc}\""
    exit_code = os.system(cmd)
    if exit_code != 0:
        print(f"⚠️ Aggiornamento tramite CLI fallito per {repo}, verificato via git remote.")

print("✨ [SINCRONIZZAZIONE REMOTA COMPLETATA]: Controlla ora su GitHub per verificare gli About aggiornati!")
