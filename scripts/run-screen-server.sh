#!/bin/bash
set -euo pipefail
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <existing runtime directory> <release directory> [Go binary]" >&2
    exit 1
fi
RUNTIME="$(cd -- "$1" && pwd)"
RELEASE="$(cd -- "$2" && pwd)"
PROJECT_ROOT="$(cd -- "$RUNTIME/.." && pwd)"
GO_BIN="${3:-}"
[[ -x "$RELEASE/adaptixserver" && -f "$RUNTIME/profile.yaml" ]]
umask 077
mkdir -p "$PROJECT_ROOT/.local/tmp" "$PROJECT_ROOT/.local/cache/go-build" \
    "$PROJECT_ROOT/.local/cache/go-mod" "$PROJECT_ROOT/.local/go"
export TMPDIR="$PROJECT_ROOT/.local/tmp/"
export GOCACHE="$PROJECT_ROOT/.local/cache/go-build"
export GOPATH="$PROJECT_ROOT/.local/go"
export GOMODCACHE="$PROJECT_ROOT/.local/cache/go-mod"
export GOTOOLCHAIN=local
if [[ -n "$GO_BIN" ]]; then
    [[ -x "$GO_BIN" ]]
    export PATH="$(dirname -- "$GO_BIN"):$PATH"
fi
cd "$RUNTIME"
exec "$RELEASE/adaptixserver" -profile "$RUNTIME/profile.yaml"
