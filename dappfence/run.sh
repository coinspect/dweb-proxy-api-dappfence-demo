#!/usr/bin/env bash
# Starts Redis, dweb-proxy-api and Caddy with the DappFence routes (dappfence/Caddyfile).
# The manifest service must already be running, e.g. in the dappfence-ens-signer devcontainer:
#   node manifest-server.mjs   (published on the host as localhost:4100)
set -euo pipefail
cd "$(dirname "$0")/.."

# Address of the trusted manifest signer (printed by signer.mjs), set in the loader page.
: "${DAPPFENCE_SIGNER:?set it to the signer address, e.g. DAPPFENCE_SIGNER=0x... bash dappfence/run.sh}"
export DAPPFENCE_SIGNER
export MANIFEST_SERVICE=${MANIFEST_SERVICE:-http://host.docker.internal:4100}
export DAPPFENCE_DIR=/tmp/dappfence/node_modules/@dappfence/core/dist
export PATCH_DIR=$PWD/dappfence
export DWEB_API_URL=http://localhost:8888

redis-server --daemonize yes --save "" --dir /tmp > /dev/null

# Same settings as local_gateway/docker-compose.yml, except IPFS: the stand-in gateway on :8090
# (see dappfence/Caddyfile) only does path-style /ipfs/<cid>/ URLs.
ETH_RPC_ENDPOINT=https://ethereum.publicnode.com \
IPFS_TARGET=http://localhost:8090 \
IPFS_SUBDOMAIN_SUPPORT=false \
LIMO_HOSTNAME_SUBSTITUTION_CONFIG=$(echo -n '{"eth.localhost": "eth", "gno.localhost": "gno"}' | base64 -w0) \
DNSQUERY_ENABLED=false \
ASK_ENABLED=false \
  npx tsx packages/dweb-api-server/src/index.ts > /tmp/dweb-proxy-api.log 2>&1 &
until curl -s -o /dev/null "$DWEB_API_URL"; do sleep 1; done

echo "Signer $DAPPFENCE_SIGNER, open http://vitalik.eth.localhost:8080 (dweb-proxy-api log: /tmp/dweb-proxy-api.log)"
caddy run --config dappfence/Caddyfile --adapter caddyfile
