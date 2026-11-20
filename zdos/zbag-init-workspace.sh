#!/bin/bash
set -e

echo "=== [zBAG / DSN] Inizializzazione Workspace edエコ系统 Strutturale ==="

PROJECT_DIR="/root/zdos/zbag-wallet"
mkdir -p "$PROJECT_DIR/src/app"
mkdir -p "$PROJECT_DIR/src/components"
mkdir -p "$PROJECT_DIR/src/features/market"
mkdir -p "$PROJECT_DIR/src/features/faucets"
mkdir -p "$PROJECT_DIR/src/features/wallet"
mkdir -p "$PROJECT_DIR/src/lib"
mkdir -p "$PROJECT_DIR/public"

# 1. plan.md - Piano approvato
cat << 'PLAN' > "$PROJECT_DIR/plan.md"
# Piano: wallet online dedicato zBAG / $DSN
- Architettura frontend React, TypeScript, Vite non-custodial (EIP-1193).
- Indirizzo Polygon $DSN: 0xfc90516a1f736FaC557e09D8853dB80dA192c296
- Integrazione prezzi Spot Binance e registro faucet pubblici verificati.
PLAN

# 2. TODO.md - Stato degli esiti
cat << 'TODO' > "$PROJECT_DIR/TODO.md"
# TODO - zBAG Wallet
- [ ] Configurazione shell dell'app in src/app/
- [ ] Implementazione moduli di connessione EIP-1193 in src/components/ e src/features/wallet/
- [ ] Connessione ticker Binance in src/features/market/
- [ ] Integrazione endpoint faucet pubblici in src/features/faucets/
TODO

# 3. WALLET_SOURCES.md - Fonti verificate
cat << 'SOURCES' > "$PROJECT_DIR/WALLET_SOURCES.md"
# WALLET SOURCES
- Binance Spot API per coppie USDT in stato TRADING.
- Polygon Network per contratto ERC-20 $DSN (0xfc90516a1f736FaC557e09D8853dB80dA192c296).
- Endpoint pubblici verificati per testnet faucet.
SOURCES

# 4. public/manus-routes.json - Route pubbliche
cat << 'ROUTES' > "$PROJECT_DIR/public/manus-routes.json"
{
  "routes": [
    "/",
    "/wallet",
    "/market",
    "/faucet",
    "/activity"
  ]
}
ROUTES

echo "=== [SUCCESS] Workspace zBAG / $DSN creato correttamente in $PROJECT_DIR ==="
