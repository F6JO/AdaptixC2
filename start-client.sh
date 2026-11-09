#!/bin/bash
set -euo pipefail
ADAPTIX_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$ADAPTIX_ROOT/scripts/native-env.sh"

CLIENT="$ADAPTIX_ROOT/build/native-client/AdaptixClient"
if [[ ! -x "$CLIENT" ]]; then
    echo "Client binary is missing. Run ./build-client.sh first; it installs no software." >&2
    exit 1
fi

cd "$ADAPTIX_ROOT"
exec "$CLIENT" "$@"
