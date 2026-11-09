#!/bin/sh
# Links the container on first start with IDLEPAY_KEY, applies IDLEPAY_DIRECT
# and a mounted /proxies.txt, then runs the agent.
# Keep /etc/idlepay on a volume so restarts reuse the same device.
set -e

if ! grep -q '"token"' "$IDLEPAY_CONFIG" 2>/dev/null; then
  if [ -z "$IDLEPAY_KEY" ]; then
    echo "IDLEPAY_KEY is not set. Create an enrollment key under Devices at https://app.idlepay.io and pass it with -e IDLEPAY_KEY=ipk_..." >&2
    exit 1
  fi
  idlepay login --key "$IDLEPAY_KEY"
fi

# Unset leaves the saved choice alone (e.g. one made with `idlepay direct off`).
case "$IDLEPAY_DIRECT" in
  "") ;;
  on|true|1) idlepay direct on ;;
  off|false|0) idlepay direct off ;;
  *) echo "IDLEPAY_DIRECT must be on or off" >&2; exit 1 ;;
esac

# A mounted proxies file is the whole list: it replaces what's saved on every
# start. Both commands fail when there is nothing to do, which isn't an error here.
if [ -f /proxies.txt ]; then
  idlepay proxy remove --all --yes >/dev/null 2>&1 || true
  if grep -q '[^[:space:]]' /proxies.txt; then
    idlepay proxy add --file /proxies.txt || echo "No usable proxies in /proxies.txt" >&2
  fi
fi

exec idlepay run --service
