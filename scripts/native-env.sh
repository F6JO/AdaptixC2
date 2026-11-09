# Shared environment for the project-local native launchers.
# ADAPTIX_ROOT is set by the calling script; system tools are only read.
: "${ADAPTIX_ROOT:?Project root must be set by the launcher}"

umask 077
export ADAPTIX_DATA_DIR="$ADAPTIX_ROOT/.local/client"
export ADAPTIX_PROJECTS_DIR="$ADAPTIX_ROOT/.local/projects"
export TMPDIR="$ADAPTIX_ROOT/.local/tmp/"
export XDG_CACHE_HOME="$ADAPTIX_ROOT/.local/cache/xdg"
export XDG_CONFIG_HOME="$ADAPTIX_ROOT/.local/config"
export QML_DISK_CACHE_PATH="$ADAPTIX_ROOT/.local/cache/qml"
export CLANG_MODULE_CACHE_PATH="$ADAPTIX_ROOT/.local/cache/clang"
export GOCACHE="$ADAPTIX_ROOT/.local/cache/go-build"
export GOPATH="$ADAPTIX_ROOT/.local/go"
export GOMODCACHE="$ADAPTIX_ROOT/.local/cache/go-mod"
export GOTOOLCHAIN=local

mkdir -p "$ADAPTIX_DATA_DIR" "$ADAPTIX_PROJECTS_DIR" "$TMPDIR" \
    "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$QML_DISK_CACHE_PATH" \
    "$CLANG_MODULE_CACHE_PATH" "$GOCACHE" "$GOPATH" "$GOMODCACHE" \
    "$ADAPTIX_ROOT/.local/logs"
