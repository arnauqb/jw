#!/bin/bash
# Build and register jw as a Claude Code plugin.
# Assembles the plugin from canonical skill + Claude integration assets.
set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_NAME="julia-warm"

# Build plugin structure in a staging directory
TARGET="$HOME/.claude/plugins/local/$PLUGIN_NAME"

echo "Building Claude plugin at: $TARGET"
rm -rf "$TARGET"
mkdir -p "$TARGET/.claude-plugin"
mkdir -p "$TARGET/skills/julia-warm/references"
mkdir -p "$TARGET/hooks/scripts"
mkdir -p "$TARGET/commands"

# Canonical skill (shared across all tools)
cp "$REPO_DIR/llm/skills/julia-warm/SKILL.md"                 "$TARGET/skills/julia-warm/SKILL.md"
cp "$REPO_DIR/llm/skills/julia-warm/references/"*              "$TARGET/skills/julia-warm/references/"

# Claude-specific assets
cp "$REPO_DIR/llm/integrations/claude/plugin.json"             "$TARGET/.claude-plugin/plugin.json"
cp "$REPO_DIR/llm/integrations/claude/hooks.json"              "$TARGET/hooks/hooks.json"
cp "$REPO_DIR/llm/integrations/claude/hooks/intercept-julia-test.sh" "$TARGET/hooks/scripts/intercept-julia-test.sh"
cp "$REPO_DIR/llm/integrations/claude/commands/jw.md"          "$TARGET/commands/jw.md"

chmod +x "$TARGET/hooks/scripts/intercept-julia-test.sh"

# Attempt registration via Claude CLI
if command -v claude >/dev/null 2>&1; then
    if claude plugins add "$TARGET" 2>/dev/null; then
        echo "Plugin registered via Claude CLI."
        exit 0
    fi
fi

# Fallback: plugin is already in ~/.claude/plugins/local/ from the copy above
if [ -d "$TARGET/.claude-plugin" ]; then
    echo "Plugin installed to: $TARGET"
    echo "Restart Claude Code for the plugin to take effect."
    exit 0
fi

# Should not reach here, but just in case
echo "Could not install plugin."
echo ""
echo "Manual alternative: copy CLAUDE.md.example into your project:"
echo "  cat $REPO_DIR/CLAUDE.md.example >> your-project/CLAUDE.md"
exit 1
