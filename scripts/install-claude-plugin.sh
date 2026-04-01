#!/bin/bash
# Register jw as a Claude Code plugin.
# Run after install.sh to enable the skill and hook in Claude Code.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Attempt 1: Use Claude CLI if available
if command -v claude >/dev/null 2>&1; then
    if claude plugins add "$SCRIPT_DIR" 2>/dev/null; then
        echo "Plugin registered via Claude CLI."
        exit 0
    fi
fi

# Attempt 2: Symlink into known plugin directory
PLUGIN_DIR="$HOME/.claude/plugins/local"
if [ -d "$HOME/.claude" ]; then
    mkdir -p "$PLUGIN_DIR"
    ln -sf "$SCRIPT_DIR" "$PLUGIN_DIR/julia-warm"
    echo "Plugin registered: $PLUGIN_DIR/julia-warm -> $SCRIPT_DIR"
    echo "Restart Claude Code for the plugin to take effect."
    exit 0
fi

# Fallback: manual instructions
echo "Could not auto-register plugin."
echo ""
echo "Option 1: Add this to your Claude Code settings (if supported):"
echo "  Plugin path: $SCRIPT_DIR"
echo ""
echo "Option 2: Use CLAUDE.md instead (always works):"
echo "  cat $SCRIPT_DIR/CLAUDE.md.example >> your-project/CLAUDE.md"
exit 1
