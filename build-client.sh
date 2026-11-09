#!/bin/bash
set -euo pipefail
ADAPTIX_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$ADAPTIX_ROOT/scripts/native-env.sh"

QT_PREFIX="${ADAPTIX_QT_PREFIX:-/opt/homebrew/opt/qt}"
OPENSSL_PREFIX="${ADAPTIX_OPENSSL_PREFIX:-/opt/homebrew/opt/openssl@3}"
if [[ ! -f "$QT_PREFIX/lib/cmake/Qt6/Qt6Config.cmake" ]]; then
    echo "Qt 6 SDK not found at $QT_PREFIX. No software has been installed." >&2
    exit 1
fi
if [[ ! -f "$OPENSSL_PREFIX/include/openssl/ssl.h" ]]; then
    echo "OpenSSL SDK not found at $OPENSSL_PREFIX. No software has been installed." >&2
    exit 1
fi

SDK_PATH="$(xcrun --sdk macosx --show-sdk-path)"
CXX_FLAGS=""
# This host has libc++ headers in its SDK, while Clang searches the CLT prefix.
if [[ -f "$SDK_PATH/usr/include/c++/v1/type_traits" ]]; then
    CXX_FLAGS="-isystem $SDK_PATH/usr/include/c++/v1"
fi

cmake -S "$ADAPTIX_ROOT/AdaptixClient" -B "$ADAPTIX_ROOT/build/native-client" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_SYSROOT="$SDK_PATH" \
    -DCMAKE_CXX_FLAGS="$CXX_FLAGS" \
    -DCMAKE_PREFIX_PATH="$QT_PREFIX" \
    -DOPENSSL_ROOT_DIR="$OPENSSL_PREFIX" \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF \
    -DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF
cmake --build "$ADAPTIX_ROOT/build/native-client" --parallel "${ADAPTIX_BUILD_JOBS:-6}"
