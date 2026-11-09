#!/bin/sh
# Links the container on first start with IDLEPAY_KEY, applies IDLEPAY_DIRECT
# and a mounted /proxies.txt, then runs the agent.
# Keep /etc/idlepay on a volume so restarts reuse the same device.
#
# Nothing here exits on a bad key or setting: under --restart always that
# would loop and re-send the sign-in on every restart. Instead it waits, and
# retries a rejected key with backoff. Once running, the agent itself waits
# (without contacting IdlePay) if its device is removed or its token rejected.
set -e
trap 'exit 0' TERM INT

# pause sleeps in the background so `docker stop` interrupts it at once.
pause() {
  sleep "$1" &
  wait $!
}

if ! grep -q '"token"' "$IDLEPAY_CONFIG" 2>/dev/null; then
  if [ -z "$IDLEPAY_KEY" ]; then
    echo "IDLEPAY_KEY is not set. Create an enrollment key under Devices at https://app.idlepay.io and recreate the container with -e IDLEPAY_KEY=ipk_... (waiting, not retrying)" >&2
    while :; do pause 3600; done
  fi
  wait_s=60
  until idlepay login --key "$IDLEPAY_KEY"; do
    jitter=$((RANDOM % (wait_s / 4 + 1)))
    echo "Sign-in with IDLEPAY_KEY failed (check the key under Devices: revoked, expired or out of uses?); retrying in $((wait_s + jitter))s" >&2
    pause $((wait_s + jitter))
    [ "$wait_s" -lt 3600 ] && wait_s=$((wait_s * 2))
    [ "$wait_s" -gt 3600 ] && wait_s=3600
  done
fi

# Unset leaves the saved choice alone (e.g. one made with `idlepay direct off`).
case "$IDLEPAY_DIRECT" in
  "") ;;
  on|true|1) idlepay direct on ;;
  off|false|0) idlepay direct off ;;
  *) echo "IDLEPAY_DIRECT must be on or off; ignoring \"$IDLEPAY_DIRECT\"" >&2 ;;
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
