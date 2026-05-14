#!/usr/bin/env bash
# Copyright(c) The Maintainers of Nanvix.
# Licensed under the MIT License.

# Thin wrapper that delegates to the nanvix-zutil CLI.
# Self-bootstraps nanvix-zutil into .nanvix/venv/ if it is not already installed.

set -euo pipefail

PINNED_VERSION="0.8.2"
RAW_ZUTIL_VERSION="${NANVIX_ZUTIL_VERSION:-$PINNED_VERSION}"
ZUTIL_VERSION="${RAW_ZUTIL_VERSION#v}"
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
VENV="$REPO_ROOT/.nanvix/venv"

function _resolve_venv_paths() {
    if [ -d "$VENV/Scripts" ]; then
        VENV_BIN="$VENV/Scripts/nanvix-zutil.exe"
        VENV_PYTHON="$VENV/Scripts/python.exe"
    else
        VENV_BIN="$VENV/bin/nanvix-zutil"
        VENV_PYTHON="$VENV/bin/python"
    fi
}
_resolve_venv_paths
ZUTIL_GLOBAL_VERSION="$(nanvix-zutil --version 2>/dev/null || true)"

function bootstrap() {
    echo "nanvix-zutil not found -- bootstrapping nanvix-zutil==${ZUTIL_VERSION}..." >&2

    if ! command -v python3 &>/dev/null; then
        echo "Error: python3 not found. Install Python 3 and ensure python3 is on PATH." >&2
        exit 1
    fi

    WHEEL_URL="https://github.com/nanvix/zutils/releases/download/v${ZUTIL_VERSION}/nanvix_zutil-${ZUTIL_VERSION}-py3-none-any.whl"
    if [ -d "$VENV" ]; then
        python3 -m venv --clear "$VENV"
    else
        python3 -m venv "$VENV"
    fi
    _resolve_venv_paths
    "$VENV_PYTHON" -m pip install --quiet "nanvix-zutil[lint] @ ${WHEEL_URL}"
}

BIN=""
if [ ! -d "$VENV" ] && [ -z "$ZUTIL_GLOBAL_VERSION" ]; then
    bootstrap
    BIN="$VENV_BIN"
elif [ -x "$VENV_BIN" ]; then
    VENV_VERSION="$("$VENV_BIN" --version 2>/dev/null || true)"
    if [ "$VENV_VERSION" != "nanvix-zutil ${ZUTIL_VERSION}" ]; then
        echo "Warning: venv nanvix-zutil version mismatch. Re-bootstrapping..." >&2
        bootstrap
    fi
    BIN="$VENV_BIN"
elif [ -d "$VENV" ] && ! command -v nanvix-zutil &>/dev/null; then
    bootstrap
    BIN="$VENV_BIN"
else
    BIN="nanvix-zutil"
fi

ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --with-nanvix=*)
            WITH_NANVIX="$(cd -- "${1#--with-nanvix=}" 2>/dev/null && pwd -P)"
            export WITH_NANVIX
            shift
            ;;
        --with-nanvix)
            WITH_NANVIX="$(cd -- "$2" 2>/dev/null && pwd -P)"
            export WITH_NANVIX
            shift 2
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

if [[ "${ARGS[0]:-}" == "distclean" ]]; then
    "$BIN" "${ARGS[@]}"
    EC=$?
    if [ -d "$VENV" ]; then rm -rf "$VENV" 2>/dev/null || true; fi
    exit $EC
fi

exec "$BIN" "${ARGS[@]}"
