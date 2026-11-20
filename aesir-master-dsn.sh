#!/bin/bash
# ÆSIR MASTER + DSN INTEGRATION
# Non distruttivo. Preserva ZLang e i repo esistenti.
set -euo pipefail

echo "=== ÆSIR MASTER + DSN ==="

WORK="$HOME/zdos-aesir"
mkdir -p "$WORK/aesir"/{policy,hybrid,nexus,scripts}
cd "$WORK"

# Clona/aggiorna repo chiave
repos=(Zlang zdos-hybrid NEXUS-X ZDOS-lab-v1 zBAG ZDOS)
for repo in "${repos[@]}"; do
  if [ ! -d "$repo" ]; then
    git clone "https://github.com/high-cde/$repo.git" || echo "Skip $repo"
  else
    (cd "$repo" && git pull --ff-only || true)
  fi
done

# Build ZLang se possibile
if [ -d "Zlang" ] && command -v cargo >/dev/null; then
  (cd Zlang && cargo build --release || true)
fi

# === DSN config ===
cat > "$WORK/aesir/dsn.env" << 'EOF'
DSN_CONTRACT=0xfc90516a1f736FaC557e09D8853dB80dA192c296
POLYGON_RPC=https://polygon-rpc.com
DSN_MIN_BALANCE_WEI=1000000000000000000
DSN_HIGH_LIMIT_WEI=10000000000000000000
DSN_HOURLY_BASE=500000000
DSN_HOURLY_BOOSTED=5000000000
EOF

# === dsn_gate.py ===
cat > "$WORK/aesir/dsn_gate.py" << 'EOF'
#!/usr/bin/env python3
import os, requests
from pathlib import Path

ENV_PATH = Path.home() / "zdos-aesir" / "aesir" / "dsn.env"
if ENV_PATH.exists():
    for line in ENV_PATH.read_text().splitlines():
        if "=" in line and not line.startswith("#"):
            k, v = line.strip().split("=", 1)
            os.environ.setdefault(k, v)

DSN = os.getenv("DSN_CONTRACT", "0xfc90516a1f736FaC557e09D8853dB80dA192c296")
RPC = os.getenv("POLYGON_RPC", "https://polygon-rpc.com")
MIN_WEI = int(os.getenv("DSN_MIN_BALANCE_WEI", "1000000000000000000"))
HIGH_WEI = int(os.getenv("DSN_HIGH_LIMIT_WEI", "10000000000000000000"))

def _call(method, params):
    r = requests.post(RPC, json={"jsonrpc":"2.0","id":1,"method":method,"params":params}, timeout=8)
    r.raise_for_status()
    return r.json()

def get_balance(address: str) -> int:
    if not address.startswith("0x") or len(address) != 42:
        return 0
    data = "0x70a08231" + address[2:].lower().zfill(64)
    result = _call("eth_call", [{"to": DSN, "data": data}, "latest"])
    return int(result.get("result", "0x0"), 16)

def has_min_dsn(address: str, min_wei=None) -> bool:
    return get_balance(address) >= (min_wei or MIN_WEI)

def get_limit_for(address: str) -> int:
    bal = get_balance(address)
    if bal >= HIGH_WEI:
        return int(os.getenv("DSN_HOURLY_BOOSTED", "5000000000"))
    if bal >= MIN_WEI:
        return int(os.getenv("DSN_HOURLY_BASE", "500000000"))
    return 0
EOF
chmod +x "$WORK/aesir/dsn_gate.py"

# === hybrid_core.py (con DSN) ===
cat > "$WORK/aesir/hybrid/hybrid_core.py" << 'EOF'
#!/usr/bin/env python3
import os, json, socket, subprocess, sys
from pathlib import Path
sys.path.insert(0, str(Path.home() / "zdos-aesir" / "aesir"))
from dsn_gate import has_min_dsn, get_limit_for

SOCK_DIR = Path("/var/run/zdos")
KIRA_SOCK = SOCK_DIR / "kira_intent.sock"
SIGN_SOCK = SOCK_DIR / "sign.sock"
POLICY_BIN = Path.home() / "zdos-aesir/aesir/policy/target/release/policy_engine"

def ensure_sockets():
    SOCK_DIR.mkdir(parents=True, exist_ok=True)
    os.chmod(SOCK_DIR, 0o770)
    for s in [KIRA_SOCK, SIGN_SOCK]:
        if s.exists(): s.unlink()

def listen_intent():
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.bind(str(KIRA_SOCK))
    os.chmod(KIRA_SOCK, 0o660)
    sock.listen(1)
    print("[hybrid] Listening (DSN-aware)")
    while True:
        conn, _ = sock.accept()
        data = conn.recv(8192)
        try:
            intent = json.loads(data.decode())
            wallet = intent.get("destination") or intent.get("requester_wallet", "")
            if intent.get("requester") != "human":
                if not has_min_dsn(wallet):
                    conn.send(json.dumps({"approved": False, "reason": "Insufficient DSN"}).encode())
                    conn.close()
                    continue
                intent["hourly_limit_override"] = get_limit_for(wallet)
            result = call_policy_engine(intent)
            if result.get("approved"):
                forward_to_sign(result, intent)
            conn.send(json.dumps(result).encode())
        except Exception as e:
            conn.send(json.dumps({"approved": False, "reason": str(e)}).encode())
        conn.close()

def call_policy_engine(intent):
    if POLICY_BIN.exists():
        proc = subprocess.run([str(POLICY_BIN)], input=json.dumps(intent).encode(), capture_output=True, timeout=5)
        if proc.returncode == 0:
            return json.loads(proc.stdout.decode())
    return {"approved": False, "reason": "policy_engine unavailable"}

def forward_to_sign(approval, intent):
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.connect(str(SIGN_SOCK))
            s.send(json.dumps({"approval": approval, "intent": intent}).encode())
    except Exception as e:
        print("[hybrid] sign failed:", e)

if __name__ == "__main__":
    ensure_sockets()
    listen_intent()
EOF
chmod +x "$WORK/aesir/hybrid/hybrid_core.py"

# === Policy engine Rust (base) ===
mkdir -p "$WORK/aesir/policy/src"
cat > "$WORK/aesir/policy/Cargo.toml" << 'EOF'
[package]
name = "policy_engine"
version = "0.1.0"
edition = "2021"
[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"
EOF

cat > "$WORK/aesir/policy/src/main.rs" << 'EOF'
use serde::{Deserialize, Serialize};
use std::io::{self, Read};

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Intent {
    pub asset: String,
    pub amount_atomic: u64,
    pub destination: String,
    pub network_constraints: Vec<String>,
    pub requester: String,
    pub hourly_limit_override: Option<u64>,
}

#[derive(Debug, Serialize)]
pub struct ApprovalToken {
    pub approved: bool,
    pub reason: String,
    pub token_hash: String,
    pub expires_unix: u64,
}

fn main() {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).ok();
    let intent: Intent = serde_json::from_str(&input).unwrap_or_else(|_| Intent {
        asset: "ZEPH".into(), amount_atomic: 0, destination: "".into(),
        network_constraints: vec![], requester: "unknown".into(), hourly_limit_override: None,
    });

    let limit = intent.hourly_limit_override.unwrap_or(500_000_000);
    let approved = intent.amount_atomic <= limit
        && intent.network_constraints.iter().any(|c| c.contains("tor") || c.contains("onion"));

    let result = if approved {
        ApprovalToken { approved: true, reason: "OK".into(), token_hash: format!("zdos-{:x}", intent.amount_atomic), expires_unix: 0 }
    } else {
        ApprovalToken { approved: false, reason: "Policy denied".into(), token_hash: "".into(), expires_unix: 0 }
    };
    println!("{}", serde_json::to_string(&result).unwrap());
}
EOF

if command -v cargo >/dev/null; then
  (cd "$WORK/aesir/policy" && cargo build --release || true)
fi

# === Nexus + Tor (minimo) ===
cat > "$WORK/aesir/nexus/package.json" << 'EOF'
{"name":"zdos-nexus","version":"1.0.0","dependencies":{"socks":"^2.7.1"}}
EOF

cat > "$WORK/aesir/nexus/torrc" << 'EOF'
SocksPort 9050
ControlPort 9051
CookieAuthentication 1
DataDirectory /var/lib/zdos-tor
EOF

# === Start script ===
cat > "$WORK/aesir/scripts/start-aesir.sh" << 'EOF'
#!/bin/bash
set -e
sudo mkdir -p /var/run/zdos /var/lib/zdos-tor
sudo chown -R $USER:$USER /var/run/zdos || true
if ! pgrep -x tor >/dev/null; then
  sudo tor -f aesir/nexus/torrc &
  sleep 2
fi
python3 aesir/hybrid/hybrid_core.py &
echo "Æsir + DSN running"
echo "Test: echo '{\"asset\":\"ZEPH\",\"amount_atomic\":1000000,\"destination\":\"0xTUO_WALLET\",\"network_constraints\":[\"tor\"],\"requester\":\"kira\"}' | socat - UNIX-CONNECT:/var/run/zdos/kira_intent.sock"
EOF
chmod +x "$WORK/aesir/scripts/start-aesir.sh"

echo ""
echo "=== COMPLETATO ==="
echo "Directory: $WORK"
echo "Avvia: cd $WORK && ./aesir/scripts/start-aesir.sh"
echo "Test saldo DSN:"
echo "python3 -c 'import sys; sys.path.insert(0,\"$WORK/aesir\"); from dsn_gate import get_balance; print(get_balance(\"0xTUO_WALLET\"))'"
