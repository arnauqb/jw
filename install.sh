#!/bin/bash
# Install jw by symlinking to ~/.local/bin
set -e

INSTALL_DIR="${1:-$HOME/.local/bin}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$INSTALL_DIR"
ln -sf "$SCRIPT_DIR/jw" "$INSTALL_DIR/jw"
chmod +x "$SCRIPT_DIR/jw"

echo "Installed: $INSTALL_DIR/jw -> $SCRIPT_DIR/jw"

if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    echo ""
    echo "Add to your PATH if not already:"
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi
