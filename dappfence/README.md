# DappFence patch

Serves `*.eth` sites through dweb-proxy-api with [DappFence](https://github.com/coinspect/dappfence)
integrity verification. The site content still comes from IPFS untouched; this adds:

- `/dappfence.js`: the DappFence service worker.
- `/integrity-manifest.json`: the site's signed manifest, loaded from a separate manifest server
  (`manifest-server.mjs` in the `dappfence-ens-signer` repo).
- `loader.html`: served on the first visit (no `dappfence=1` cookie) to install the service worker,
  then reloads into the real site.
- `attack.sh`: toggles a simulated compromised gateway that serves a blog post with a malicious script.

`Caddyfile` imports local_gateway's Caddy config unchanged and adds these routes.

## Demo

In the `dappfence-ens-signer` devcontainer, sign and serve the manifest:

```sh
node signer.mjs vitalik.eth      # prints the signer address
node manifest-server.mjs         # published on the host as localhost:4100
```

Then, in this repo's "dweb-proxy-api + DappFence" devcontainer, start the gateway with the signer
address. It loads the manifests from that manifest server:

```sh
DAPPFENCE_SIGNER=<address printed by signer.mjs> bash dappfence/run.sh
```

1. Open http://vitalik.eth.localhost:8080. The first visit installs DappFence and reloads.
2. `bash dappfence/attack.sh` turns the attack on (run it again to turn it off).
3. Open http://vitalik.eth.localhost:8080/general/2026/09/27/the_cryptographic_world_computer.html:
   the DappFence warning page.
