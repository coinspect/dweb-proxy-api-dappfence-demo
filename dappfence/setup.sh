#!/usr/bin/env bash
# Installs Redis, Caddy, DappFence and the dweb-proxy-api dependencies.
set -euo pipefail

sudo apt-get update -qq
sudo apt-get install -y -qq redis-server

CADDY_VERSION=2.11.2
ARCH=$(dpkg --print-architecture)
curl -fsSL "https://github.com/caddyserver/caddy/releases/download/v${CADDY_VERSION}/caddy_${CADDY_VERSION}_linux_${ARCH}.tar.gz" \
  | sudo tar -xz -C /usr/local/bin caddy

npm ci --ignore-scripts
for p in dweb-api-types dweb-api-logger dweb-api-cache dweb-api-resolver; do
  npm run build -w "packages/$p"
done

# DappFence service worker, served by Caddy as /dappfence.js
npm install --prefix /tmp/dappfence --no-save --silent @dappfence/core@0.1.2
