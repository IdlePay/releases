#!/bin/sh
# Links the container on first start with IDLEPAY_KEY, then runs the agent.
# Keep /etc/idlepay on a volume so restarts reuse the same device.
set -e

if ! grep -q '"token"' "$IDLEPAY_CONFIG" 2>/dev/null; then
  if [ -z "$IDLEPAY_KEY" ]; then
    echo "IDLEPAY_KEY is not set. Create an enrollment key under Devices at https://app.idlepay.io and pass it with -e IDLEPAY_KEY=ipk_..." >&2
    exit 1
  fi
  idlepay login --key "$IDLEPAY_KEY"
fi

exec idlepay run --service
