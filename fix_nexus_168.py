import os
import subprocess
import time
import urllib.request

NEXUS_JS = "/opt/zdos-omni-nexus/nexus.js"

with open(NEXUS_JS, "r", encoding="utf-8") as f:
    lines = f.readlines()

changed = False
for idx, line in enumerate(lines):
    if "await sock.requestPairingCode(" in line:
        indent = line[: len(line) - len(line.lstrip())]
        stripped = line.strip()
        # Evita doppio wrap se già fixato
        prev_ctx = "".join(lines[max(0, idx - 3) : idx])
        if "(async () => {" not in prev_ctx:
            lines[idx] = (
                f"{indent}const code = await (async () => {{ return {stripped.replace('const code = await ', '').rstrip(';')}; }})();\n"
            )
            changed = True

if changed:
    with open(NEXUS_JS, "w", encoding="utf-8") as f:
        f.writelines(lines)
    print("✅ Riga con requestPairingCode messa in sicurezza dentro funzione async")
else:
    print("ℹ️ Nessuna modifica necessaria su requestPairingCode")

subprocess.run(["pm2", "restart", "zdos-omni-nexus"], check=False)
subprocess.run(["pm2", "save"], check=False)
time.sleep(2)

for path in ["/api/aggregator", "/api/payment-wallet", "/api/mistress-legal-finance"]:
    url = f"http://127.0.0.1:8899{path}"
    try:
        with urllib.request.urlopen(url, timeout=5) as resp:
            body = resp.read().decode("utf-8", errors="replace")
            print(f"✅ {path} -> HTTP {resp.status} ({len(body)} bytes)")
    except Exception as exc:
        print(f"⚠️ {path} -> {exc}")
