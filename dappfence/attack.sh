#!/usr/bin/env bash
# Toggles a simulated compromised gateway: when on, it serves a blog post with a malicious
# script appended, instead of the real one from IPFS.
#
#   bash dappfence/attack.sh   turn the attack on, or off if it is already on
set -euo pipefail
dir="$(dirname "$0")/attacker"
page=/general/2026/09/27/the_cryptographic_world_computer.html

if [ -d "$dir" ]; then
  rm -rf "$dir"
  echo "Attack OFF: the gateway serves the real files again."
else
  real=$(curl -fsS -H "Host: vitalik.eth.localhost:8080" -H "Cookie: dappfence=1" "localhost:8080$page")
  mkdir -p "$dir$(dirname "$page")"
  printf '%s\n<script>alert("injected by attacker")</script>\n' "$real" > "$dir$page"
  echo "Attack ON: the gateway now serves a malicious $page"
fi
