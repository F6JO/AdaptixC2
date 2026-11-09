#!/bin/bash
set -euo pipefail
ADAPTIX_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STATE_ROOT="${ADAPTIX_STATE_ROOT:-$ADAPTIX_ROOT/.local}"
OUTPUT="${1:-$ADAPTIX_ROOT/build/linux-server}"
GO_BIN="${ADAPTIX_GO:-go}"
JOBS="${ADAPTIX_BUILD_JOBS:-1}"

if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
    echo "Build this release on Linux x86_64 with an existing Go >= 1.25.4 toolchain." >&2
    exit 1
fi
command -v "$GO_BIN" >/dev/null
command -v x86_64-w64-mingw32-g++ >/dev/null
if [[ -e "$OUTPUT" ]]; then
    echo "Output already exists; choose a new empty release path: $OUTPUT" >&2
    exit 1
fi
mkdir -p "$OUTPUT" "$STATE_ROOT/tmp" "$STATE_ROOT/cache/go-build" \
    "$STATE_ROOT/cache/go-mod" "$STATE_ROOT/go" "$STATE_ROOT/logs"
OUTPUT="$(cd -- "$OUTPUT" && pwd)"
STATE_ROOT="$(cd -- "$STATE_ROOT" && pwd)"
export TMPDIR="$STATE_ROOT/tmp/"
export GOCACHE="$STATE_ROOT/cache/go-build"
export GOPATH="$STATE_ROOT/go"
export GOMODCACHE="$STATE_ROOT/cache/go-mod"
export GOTOOLCHAIN=local
export GOEXPERIMENT=jsonv2,greenteagc
export CGO_ENABLED=1
export GOMEMLIMIT="${GOMEMLIMIT:-600MiB}"
export GOGC="${GOGC:-50}"
export GOFLAGS="-p=$JOBS"
export PATH="$(dirname -- "$(command -v "$GO_BIN")"):$PATH"

echo "Building server and plugins with $($GO_BIN version)"
(cd "$ADAPTIX_ROOT/AdaptixServer" && "$GO_BIN" build -buildvcs=false -ldflags='-s -w' -o "$OUTPUT/adaptixserver" .)
cp "$ADAPTIX_ROOT/AdaptixServer/404page.html" "$OUTPUT/404page.html"
mkdir -p "$OUTPUT/extenders"
for module in beacon_listener_http beacon_listener_smb beacon_listener_tcp beacon_listener_dns beacon_agent gopher_listener_tcp gopher_agent; do
    source_dir="$ADAPTIX_ROOT/AdaptixServer/extenders/$module"
    target_dir="$OUTPUT/extenders/$module"
    plugin_file="$(sed -n 's/^extender_file: *"\([^"]*\)".*/\1/p' "$source_dir/config.yaml")"
    [[ -n "$plugin_file" && "$plugin_file" != */* ]]
    mkdir -p "$target_dir"
    cp "$source_dir/config.yaml" "$source_dir/ax_config.axs" "$target_dir/"
    echo "Building $module"
    (cd "$source_dir" && "$GO_BIN" build -buildvcs=false -buildmode=plugin -ldflags='-s -w' -o "$target_dir/$plugin_file" .)
done

# Build fresh Windows objects from this checkout; never copy host Go plugins.
BEACON_SOURCE="$STATE_ROOT/beacon-build-$(date +%s)-$$"
mkdir -p "$BEACON_SOURCE"
cp -R "$ADAPTIX_ROOT/AdaptixServer/extenders/beacon_agent/src_beacon/beacon" "$BEACON_SOURCE/"
cp -R "$ADAPTIX_ROOT/AdaptixServer/extenders/beacon_agent/src_beacon/files" "$BEACON_SOURCE/"
cp "$ADAPTIX_ROOT/AdaptixServer/extenders/beacon_agent/src_beacon/Makefile" "$BEACON_SOURCE/"
make -C "$BEACON_SOURCE" NPROC="$JOBS" pre
make -C "$BEACON_SOURCE" -j"$JOBS" NPROC="$JOBS" x64
if command -v i686-w64-mingw32-g++ >/dev/null; then
    make -C "$BEACON_SOURCE" -j"$JOBS" NPROC="$JOBS" x86
else
    echo "x86 compiler is absent; this release includes Windows x64 objects only."
fi
for protocol in http smb tcp dns; do
    cp -R "$BEACON_SOURCE/objects_$protocol" "$OUTPUT/extenders/beacon_agent/"
done
cp -R "$ADAPTIX_ROOT/AdaptixServer/extenders/gopher_agent/src_gopher" "$OUTPUT/extenders/gopher_agent/"
git -C "$ADAPTIX_ROOT" rev-parse HEAD > "$OUTPUT/REVISION"
echo 'standard (IAT Hiding disabled)' > "$OUTPUT/BUILD_VARIANT"
echo "Release built at $OUTPUT; configuration, certificates, and data were not copied."
