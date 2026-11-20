#!/usr/bin/env python3
import http.server
import json
import urllib.parse
import threading
import time
import os
from datetime import datetime

PORT = 8082
DB_FILE = "/root/zdos/faucet_db.json"

TOKENS = {
    "DSN": {"name": "Netkali DSN", "auto_amount": 1.0},
    "BTC": {"name": "Bitcoin", "auto_amount": 0.00001},
    "ETH": {"name": "Ethereum", "auto_amount": 0.0001},
    "POL": {"name": "Polygon (MATIC)", "auto_amount": 0.1},
    "DOGE": {"name": "Dogecoin", "auto_amount": 0.5},
    "LTC": {"name": "Litecoin", "auto_amount": 0.001},
    "SHIB": {"name": "Shiba Inu", "auto_amount": 100.0},
    "ZEC": {"name": "Zcash", "auto_amount": 0.001}
}

db_lock = threading.Lock()

def load_db():
    if os.path.exists(DB_FILE):
        try:
            with open(DB_FILE, "r") as f:
                return json.load(f)
        except Exception:
            pass
    return {}

def save_db():
    with db_lock:
        try:
            with open(DB_FILE, "w") as f:
                json.dump(REGISTERED_USERS, f, indent=2)
        except Exception as e:
            print(f"Errore salvataggio DB: {e}")

REGISTERED_USERS = load_db()
LAST_CLAIM = {} # { "username_token": timestamp }

def autonomous_airdrop_worker():
    while True:
        time.sleep(300) # Ogni 5 minuti
        with db_lock:
            if REGISTERED_USERS:
                for username, data in REGISTERED_USERS.items():
                    for token, info in TOKENS.items():
                        amt = info["auto_amount"]
                        data["balances"][token] = data["balances"].get(token, 0.0) + amt
                save_db()

class FaucetHandler(http.server.BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def send_cors_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Content-Type", "application/json")

    def do_GET(self):
        parsed_path = urllib.parse.urlparse(self.path)
        if parsed_path.path == "/faucet/status":
            self.send_response(200)
            self.send_cors_headers()
            self.end_headers()
            response = {
                "status": "online",
                "service": "netkali-autonomous-faucet-persistent",
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
                    self.send_cors_headers()
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": "user_not_found"}).encode("utf-8"))
                    return
                user_data = REGISTERED_USERS[username]
                self.send_response(200)
                self.send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({"success": True, "username": username, "balances": user_data["balances"]}).encode("utf-8"))
        else:
            self.send_response(404)
            self.send_cors_headers()
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
                    self.send_cors_headers()
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
                        save_db()
                self.send_response(200)
                self.send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({
                    "success": True,
                    "message": f"User '{username}' registered with persistence.",
                    "balances": REGISTERED_USERS[username]["balances"]
                }).encode("utf-8"))
            elif parsed_path.path == "/faucet/claim":
                token = data.get("token", "DSN").upper()
                username = data.get("username")
                if not username or username not in REGISTERED_USERS:
                    self.send_response(400)
                    self.send_cors_headers()
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": "user_not_registered"}).encode("utf-8"))
                    return
                if token not in TOKENS:
                    self.send_response(400)
                    self.send_cors_headers()
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": "unsupported_token"}).encode("utf-8"))
                    return

                # Rate limiting 30 secondi per claim manuale
                claim_key = f"{username}_{token}"
                now_ts = time.time()
                if claim_key in LAST_CLAIM and now_ts - LAST_CLAIM[claim_key] < 30:
                    self.send_response(429)
                    self.send_cors_headers()
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": "rate_limit_exceeded", "message": "Attendi 30 secondi tra un claim e l'altro."}).encode("utf-8"))
                    return

                LAST_CLAIM[claim_key] = now_ts
                reward = TOKENS[token]["auto_amount"] * 5
                with db_lock:
                    REGISTERED_USERS[username]["balances"][token] += reward
                    save_db()

                response = {
                    "success": True,
                    "token": token,
                    "claimed_amount": reward,
                    "username": username,
                    "new_balance": REGISTERED_USERS[username]["balances"][token]
                }
                self.send_response(200)
                self.send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps(response).encode("utf-8"))
            else:
                self.send_response(404)
                self.send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({"error": "endpoint_not_found"}).encode("utf-8"))
        except Exception as e:
            self.send_response(500)
            self.send_cors_headers()
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))

if __name__ == "__main__":
    t = threading.Thread(target=autonomous_airdrop_worker, daemon=True)
    t.start()
    server = http.server.HTTPServer(("127.0.0.1", PORT), FaucetHandler)
    print(f"Netkali Persistent Faucet running on port {PORT}...")
    server.serve_forever()
