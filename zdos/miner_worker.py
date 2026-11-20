import hashlib
import time
import os

print("⛏️ [ZAI-MINER REALE]: Avvio calcolo proof-of-work sinaptico su VPS Contabo...")
difficulty = 4
target = "0" * difficulty

nonce = 0
start_time = time.time()
hashes = 0

while True:
    data = f"ZDOS-ZLANG-BLOCK-{nonce}-{time.time()}"
    h = hashlib.sha256(data.encode()).hexdigest()
    hashes += 1
    
    if h.startswith(target):
        elapsed = time.time() - start_time
        if elapsed > 0:
            khs = (hashes / elapsed) / 1000
            print(f"[BLOCK MINED]: Hash trovato! Nonce: {nonce} | Velocità: {khs:.2f} kH/s | Hex: {h[:16]}...")
            with open('/root/zdos/mining_status.json', 'w') as f:
                f.write(f'{{"hashRate": "{khs:.2f}", "lastBlock": "{h[:16]}", "status": "active"}}')
        start_time = time.time()
        hashes = 0
    
    nonce += 1
    if nonce > 1000000:
        nonce = 0
