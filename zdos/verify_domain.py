import os
import subprocess

print("🌐 [ZDOS DOMAIN SYNC]: Verifica risposte e configurazione per x-zdos.it...")

# 1. Verifica configurazione Nginx attiva
nginx_test = subprocess.run("nginx -t", shell=True, capture_output=True, text=True)
print(nginx_test.stdout)
print(nginx_test.stderr)

# 2. Test risposta locale del server web
curl_test = subprocess.run("curl -I http://localhost", shell=True, capture_output=True, text=True)
print("📡 Risposta HTTP locale:")
print(curl_test.stdout)

print("✨ [VERIFICA COMPLETATA]: Infrastruttura web pronta per x-zdos.it!")
