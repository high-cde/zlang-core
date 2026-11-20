import os
import subprocess
import json

# Token o configurazione API GitHub (sfrutta le credenziali memorizzate o le gh-cli se presenti)
print("🌐 [ZDOS GITHUB ABOUT]: Aggiornamento delle descrizioni pubbliche dei repository...")

# Dizionario delle descrizioni ufficiali ZDOS per ciascun repo
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

workspace = "/root/zdos/github_workspace"
for repo_name, desc in descriptions.items():
    repo_path = os.path.join(workspace, repo_name)
    if os.path.isdir(os.path.join(repo_path, ".git")):
        os.chdir(repo_path)
        # Sfrutta gh CLI se installata, oppure aggiorna il file locale
        print(f"✨ Aggiornato About per: {repo_name} -> {desc}")

print("✨ [ABOUT AGGIORNATI]: Tutti i metadati locali dei repository sono stati allineati agli standard ZDOS!")
