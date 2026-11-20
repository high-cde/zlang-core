#!/bin/bash
set -e

echo "=== [ZDOS & Netkali] Avvio Autobuild e Deployment Completo ==="

# 1. Creazione / Aggiornamento del Faucet Multi-Token Backend
echo "[+] Configurazione del Faucet Backend autonomo (porta 8082)..."
cat << 'PYTHON_EOF' > /root/zdos/faucet_backend.py
#!/usr/bin/env python3
import http.server
import json
import urllib.parse
import threading
import time
from datetime import datetime

PORT = 8082

TOKENS = {
    "DSN": {"name": "Netkali DSN", "auto_amount": 1.0, "type": "native"},
    "BTC": {"name": "Bitcoin", "auto_amount": 0.00001, "type": "crypto"},
    "ETH": {"name": "Ethereum", "auto_amount": 0.0001, "type": "crypto"},
    "POL": {"name": "Polygon (MATIC)", "auto_amount": 0.1, "type": "token"},
    "DOGE": {"name": "Dogecoin", "auto_amount": 0.5, "type": "crypto"},
    "LTC": {"name": "Litecoin", "auto_amount": 0.001, "type": "crypto"},
    "SHIB": {"name": "Shiba Inu", "auto_amount": 100.0, "type": "token"},
    "ZEC": {"name": "Zcash", "auto_amount": 0.001, "type": "crypto"}
}

REGISTERED_USERS = {}
db_lock = threading.Lock()

def autonomous_airdrop_worker():
    while True:
        time.sleep(300) # Ogni 5 minuti
        with db_lock:
            if REGISTERED_USERS:
                for username, data in REGISTERED_USERS.items():
                    for token, info in TOKENS.items():
                        amt = info["auto_amount"]
                        data["balances"][token] = data["balances"].get(token, 0.0) + amt

class FaucetHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        parsed_path = urllib.parse.urlparse(self.path)
        if parsed_path.path == "/faucet/status":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            response = {
                "status": "online",
                "service": "netkali-autonomous-faucet",
                "interval_seconds": 300,
                "supported_tokens": list(TOKENS.keys()),
                "registered_users_count": len(REGISTERED_USERS)
            }
            self.wfile.write(json.dumps(response).encode("utf-8"))
        elif parsed_path.path.startswith("/user/balances"):
            query_params = urllib.parse.parse_qs(parsed_path.query)
            username = query_params.get("username", [None])[0]
            with db_lock:
                if not username or username not in REGISTERED_USERS:
                    self.send_response(404)
                    self.send_header("Content-Type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": "user_not_found"}).encode("utf-8"))
                    return
                user_data = REGISTERED_USERS[username]
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"success": True, "username": username, "balances": user_data["balances"]}).encode("utf-8"))
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'{"error": "not_found"}')

    def do_POST(self):
        parsed_path = urllib.parse.urlparse(self.path)
        content_length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(content_length)
        try:
            data = json.loads(post_data.decode('utf-8'))
            if parsed_path.path == "/user/register":
                username = data.get("username")
                if not username:
                    self.send_response(400)
                    self.send_header("Content-Type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": "missing_username"}).encode("utf-8"))
                    return
                with db_lock:
                    if username not in REGISTERED_USERS:
                        initial_balances = {t: 0.0 for t in TOKENS}
                        REGISTERED_USERS[username] = {
                            "balances": initial_balances,
                            "registered_at": datetime.now().isoformat()
                        }
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({
                    "success": True,
                    "message": f"User '{username}' registered. Autonomous 5-min multi-token airdrop active!",
                    "balances": REGISTERED_USERS[username]["balances"]
                }).encode("utf-8"))
            elif parsed_path.path == "/faucet/claim":
                token = data.get("token", "DSN").upper()
                username = data.get("username")
                if not username or username not in REGISTERED_USERS:
                    self.send_response(400)
                    self.send_header("Content-Type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": "user_not_registered"}).encode("utf-8"))
                    return
                if token not in TOKENS:
                    self.send_response(400)
                    self.send_header("Content-Type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": "unsupported_token"}).encode("utf-8"))
                    return
                reward = TOKENS[token]["auto_amount"] * 5
                with db_lock:
                    REGISTERED_USERS[username]["balances"][token] += reward
                response = {
                    "success": True,
                    "token": token,
                    "claimed_amount": reward,
                    "username": username,
                    "new_balance": REGISTERED_USERS[username]["balances"][token]
                }
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps(response).encode("utf-8"))
            else:
                self.send_response(404)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "endpoint_not_found"}).encode("utf-8"))
        except Exception as e:
            self.send_response(500)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))

if __name__ == "__main__":
    t = threading.Thread(target=autonomous_airdrop_worker, daemon=True)
    t.start()
    server = http.server.HTTPServer(("127.0.0.1", PORT), FaucetHandler)
    print(f"Netkali Autonomous Multi-Token Faucet running on port {PORT}...")
    server.serve_forever()
PYTHON_EOF

chmod +x /root/zdos/faucet_backend.py

# 2. Gestione dei processi con PM2
echo "[+] Pulizia e avvio dei servizi tramite PM2..."
pm2 delete zdos-interface-backend || true
pm2 delete netkali-faucet || true

# Avvio del backend principale Node.js sulla porta 8081
cd /root/zdos/github_workspace/ZDOS/interface/web
PORT=8081 pm2 start server/server.js --name "zdos-interface-backend"

# Avvio del faucet multi-token Python sulla porta 8082
pm2 start /root/zdos/faucet_backend.py --name "netkali-faucet"

# Salvataggio dello stato PM2
pm2 save

echo "=== [SUCCESS] Autobuild completato con successo! Tutti i servizi sono online. ==="
pm2 status
