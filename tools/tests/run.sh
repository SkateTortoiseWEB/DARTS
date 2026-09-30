#!/bin/bash
# Runs the app checks: starts the Oche server on port 8765 with a throwaway data folder, runs both test files, stops it.
# Needs Playwright (these scripts import it from /opt/node22/lib/node_modules/playwright; change that path if yours differs).
cd "$(dirname "$0")"
DATA=$(mktemp -d)
OCHE_ROOT=../../Oche.app/Contents/Resources OCHE_DATA_DIR="$DATA" OCHE_PORT=8765 python3 ../../Oche.app/Contents/Resources/server.py >/dev/null 2>&1 &
SERVER=$!
sleep 1
node game-flows.mjs; node camera-flows.mjs
kill $SERVER; rm -rf "$DATA"
