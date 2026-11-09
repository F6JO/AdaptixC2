#!/bin/bash
set -euo pipefail
ADAPTIX_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$ADAPTIX_ROOT/scripts/native-env.sh"

if [[ ! -x "$ADAPTIX_ROOT/dist/adaptixserver" || ! -f "$ADAPTIX_ROOT/.local/server/profile.yaml" ]]; then
    echo "Local server binary or configuration is missing. See LOCAL_RUN.md." >&2
    exit 1
fi

cd "$ADAPTIX_ROOT/.local/server"
exec "$ADAPTIX_ROOT/dist/adaptixserver" -profile profile.yaml "$@"
