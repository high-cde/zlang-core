#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/opt/zdos-build
OUT=/opt/zdos-supernode
DATA=/var/lib/zdos-supernode
SERVICE=zdos-supernode.service
PORT=8790
LOG="/var/log/zdos-supernode-$(date +%Y%m%d-%H%M%S).log"

exec > >(tee -a "$LOG") 2>&1

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "comando mancante: $1"
}

echo "=== ZDOS SUPER-NODE CREATOR ==="
echo "ROOT=$ROOT"
echo "OUT=$OUT"
echo "DATA=$DATA"
echo "LOG=$LOG"

[ "$(id -u)" -eq 0 ] || fail "eseguire come root"

for repo in ZDOS Zlang ZDOS-lab-v1 zdos-microcosm-beta; do
  [ -d "$ROOT/$repo/.git" ] || fail "repository mancante: $ROOT/$repo"
done

for cmd in git python3 node sha256sum systemctl; do
  require_cmd "$cmd"
done

mkdir -p "$OUT" "$DATA" /var/log

if [ -e "/etc/systemd/system/$SERVICE" ]; then
  cp -a "/etc/systemd/system/$SERVICE" \
    "/etc/systemd/system/$SERVICE.backup.$(date +%Y%m%d-%H%M%S)"
fi

if [ -d "$OUT" ]; then
  cp -a "$OUT" "${OUT}.backup.$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true
fi

echo
echo "=== REPOSITORY COMMITS ==="
for repo in ZDOS Zlang ZDOS-lab-v1 zdos-microcosm-beta; do
  DIRTY="$(git -C "$ROOT/$repo" status --porcelain=v1 | grep -Ev ' (target/|.*/__pycache__/|__pycache__/)' || true)"
  [ -z "$DIRTY" ] || {
    printf "%s\n" "$DIRTY"
    fail "$repo ha modifiche sorgente locali"
  }
  git -C "$ROOT/$repo" log -1 --format="$repo %H %cI %s"
done

echo
echo "=== ZLANG TESTS ==="
cd "$ROOT/Zlang"
python3 -m unittest discover -s tests -p 'test_*.py' -v

if command -v cargo >/dev/null 2>&1; then
  cargo fmt --all -- --check
  cargo check --all-targets
else
  echo "WARN: cargo assente; check Rust non eseguito"
fi

python3 tests/test_storage_read_v1.py

echo
echo "=== ZLANG NATIVE PROBE ==="
cat >"$OUT/supernode-probe.zlang" <<'ZLANG'
# ZDOS super-node native probe
emit ZDOS super-node Zlang probe accepted
emit ZLB2 v2.5 contract verified
ZLANG

python3 "$ROOT/Zlang/tools/zlangc.py" \
  "$OUT/supernode-probe.zlang" \
  --bytecode "$OUT/supernode-probe.zlb" \
  --header "$OUT/supernode-probe.h"

[ -s "$OUT/supernode-probe.zlb" ] || fail "bytecode ZLB2 non generato"
[ -s "$OUT/supernode-probe.h" ] || fail "header ZLB2 non generato"

BYTECODE_MAGIC="$(od -An -tx1 -N4 "$OUT/supernode-probe.zlb" | tr -d ' \\n')"
[ "$BYTECODE_MAGIC" = "5a4c4232" ] \
  || fail "bytecode privo della magic ZLB2: $BYTECODE_MAGIC"

echo
echo "=== ZDOS SOURCE TESTS ==="
cd "$ROOT/ZDOS"

if [ -x tools/zdos-selftest.sh ]; then
  ZLANG_ROOT="$ROOT/Zlang" ./tools/zdos-selftest.sh --all
else
  echo "WARN: self-test ZDOS non trovato"
fi

echo
echo "=== LAB GATE ==="
cd "$ROOT/ZDOS-lab-v1"
./orchestration/zdos-labctl inspect
./orchestration/zdos-labctl gate

echo
echo "=== ARTIFACT HASHES ==="
sha256sum \
  "$OUT/supernode-probe.zlang" \
  "$OUT/supernode-probe.zlb" \
  "$OUT/supernode-probe.h" \
  >"$OUT/SHA256SUMS"

ZDOS_COMMIT="$(git -C "$ROOT/ZDOS" rev-parse HEAD)"
ZLANG_COMMIT="$(git -C "$ROOT/Zlang" rev-parse HEAD)"
LAB_COMMIT="$(git -C "$ROOT/ZDOS-lab-v1" rev-parse HEAD)"
MICROCOSM_COMMIT="$(git -C "$ROOT/zdos-microcosm-beta" rev-parse HEAD)"
PROBE_SHA="$(sha256sum "$OUT/supernode-probe.zlb" | awk '{print $1}')"

cat >"$OUT/node-manifest.json" <<JSON
{
  "schema": "zdos.supernode.manifest.v1",
  "node_id": "VPS-2FAFE589",
  "status": "STAGED",
  "policy": "DEFAULT-DENY",
  "network": "LOCAL-ONLY",
  "tx": "DENIED",
  "native_language": "Zlang",
  "bytecode": "ZLB2 v2.5",
  "compiler": "Zlang/tools/zlangc.py",
  "current_runtime": "zdos-node.service TypeScript bridge",
  "native_probe_sha256": "$PROBE_SHA",
  "official_zlang_profile": [
    "emit",
    "storage.read",
    "HALT"
  ],
  "legacy_bridge_profile": [
    "node.status",
    "node.capabilities",
    "gps.status",
    "radio.status",
    "radio.receive",
    "zcomm.queue",
    "evidence.commit",
    "halt"
  ],
  "legacy_bridge_profile_status": "NOT_YET_FORMALIZED_IN_ZLB2",
  "repositories": {
    "ZDOS": "$ZDOS_COMMIT",
    "Zlang": "$ZLANG_COMMIT",
    "ZDOS-lab-v1": "$LAB_COMMIT",
    "zdos-microcosm-beta": "$MICROCOSM_COMMIT"
  },
  "integration": {
    "existing_node": "http://127.0.0.1:8787",
    "supernode_adapter": "http://127.0.0.1:$PORT",
    "microcosm_public_route": "NOT_EXPOSED_YET"
  }
}
JSON

echo
echo "=== CREATE LOCAL SUPER-NODE ADAPTER ==="

cat >"$OUT/supernode-adapter.mjs" <<'NODE'
import http from "node:http";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { readFile, appendFile, mkdir } from "node:fs/promises";
import { createHash, randomUUID } from "node:crypto";

const execFileAsync = promisify(execFile);
const HOST = "127.0.0.1";
const PORT = 8790;
const ROOT = "/opt/zdos-build";
const OUT = "/opt/zdos-supernode";
const DATA = "/var/lib/zdos-supernode";
const ZLANGC = `${ROOT}/Zlang/tools/zlangc.py`;
const MANIFEST = `${OUT}/node-manifest.json`;
const EVENTS = `${DATA}/events.jsonl`;

await mkdir(DATA, { recursive: true });

function json(res, code, body) {
  res.writeHead(code, {
    "content-type": "application/json; charset=utf-8",
    "cache-control": "no-store"
  });
  res.end(JSON.stringify(body));
}

async function body(req) {
  let result = "";
  for await (const chunk of req) result += String(chunk);
  try {
    return JSON.parse(result || "{}");
  } catch {
    return {};
  }
}

async function audit(action, outcome, metadata = {}) {
  const event = {
    id: randomUUID(),
    at: new Date().toISOString(),
    action,
    outcome,
    metadata
  };
  await appendFile(EVENTS, JSON.stringify(event) + "\n");
}

async function compileSource(source) {
  const digest = createHash("sha256").update(source).digest("hex");
  const base = `${DATA}/request-${Date.now()}`;
  const src = `${base}.zlang`;
  const zlb = `${base}.zlb`;
  const hdr = `${base}.h`;

  await import("node:fs/promises").then(({ writeFile }) =>
    writeFile(src, source, { mode: 0o600 })
  );

  try {
    const result = await execFileAsync("python3", [
      ZLANGC,
      src,
      "--bytecode",
      zlb,
      "--header",
      hdr
    ], { timeout: 15000 });

    await audit("zlang.compile", "ACCEPTED", {
      source_sha256: digest,
      compiler: ZLANGC,
      bytecode: zlb
    });

    return {
      status: "ACCEPTED",
      source_sha256: digest,
      compiler: "Zlang/tools/zlangc.py",
      bytecode: "ZLB2 v2.5",
      stdout: result.stdout.trim()
    };
  } catch (error) {
    await audit("zlang.compile", "DENIED", {
      source_sha256: digest,
      reason: String(error.stderr || error.message || "compile failed").slice(0, 1000)
    });

    return {
      status: "DENIED",
      source_sha256: digest,
      detail: String(error.stderr || error.message || "compile failed").slice(0, 1000)
    };
  }
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url || "/", `http://${HOST}:${PORT}`);

  if (req.method === "GET" && url.pathname === "/health") {
    return json(res, 200, {
      ok: true,
      service: "zdos-supernode-adapter",
      runtime: "ZDOS",
      language: "Zlang",
      bytecode: "ZLB2 v2.5",
      policy: "DEFAULT-DENY",
      native_execution: "compile-and-verify",
      existing_node: "127.0.0.1:8787"
    });
  }

  if (req.method === "GET" && url.pathname === "/v1/manifest") {
    return json(res, 200, JSON.parse(await readFile(MANIFEST, "utf8")));
  }

  if (req.method === "POST" && url.pathname === "/v1/zlang/compile") {
    const input = await body(req);
    const source = typeof input.source === "string" ? input.source : "";
    if (!source || source.length > 16384) {
      return json(res, 400, {
        status: "DENIED",
        detail: "source required and limited to 16384 bytes"
      });
    }
    return json(res, 200, await compileSource(source));
  }

  return json(res, 404, { error: "not found" });
});

server.listen(PORT, HOST, () => {
  console.log(`ZDOS supernode adapter listening on ${HOST}:${PORT}`);
});
NODE

chmod 750 "$OUT/supernode-adapter.mjs"
chown -R root:root "$OUT"
chmod 750 "$OUT"
chmod 700 "$DATA"

echo
echo "=== CREATE SYSTEMD UNIT ==="

cat >"/etc/systemd/system/$SERVICE" <<UNIT
[Unit]
Description=ZDOS Super-node ZLang/ZLB2 adapter
After=network.target zdos-node.service
Wants=zdos-node.service

[Service]
Type=simple
User=zdos-node
Group=zdos-node
WorkingDirectory=$OUT
ExecStart=/usr/bin/node $OUT/supernode-adapter.mjs
Restart=on-failure
RestartSec=3
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$DATA
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now "$SERVICE"

sleep 2

systemctl is-active --quiet "$SERVICE" \
  || fail "il servizio $SERVICE non è attivo"

echo
echo "=== LIVE LOCAL CHECKS ==="
curl -fsS http://127.0.0.1:$PORT/health
echo
curl -fsS http://127.0.0.1:$PORT/v1/manifest
echo

echo
echo "=== SUPER-NODE READY ==="
echo "Manifest: $OUT/node-manifest.json"
echo "Artifacts: $OUT"
echo "Adapter: http://127.0.0.1:$PORT"
echo "Existing node preserved: zdos-node.service"
echo "Log: $LOG"
