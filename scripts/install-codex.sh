#!/bin/bash
# Install the julia-warm skill into a project for Codex.
# Copies the canonical skill to .agents/skills/julia-warm/ in the target project.
set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Determine target project directory
if [ -n "$1" ]; then
    PROJECT_DIR="$(cd "$1" 2>/dev/null && pwd)" || { echo "Directory not found: $1"; exit 1; }
else
    PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null)" || {
        echo "Usage: install-codex.sh [project-dir]"
        echo ""
        echo "If no directory is provided, uses the current git repo root."
        echo "Run from inside your Julia project, or pass the path explicitly."
        exit 1
    }
fi

TARGET="$PROJECT_DIR/.agents/skills/julia-warm"

echo "Installing julia-warm skill to: $TARGET"
mkdir -p "$TARGET/references"

cp "$REPO_DIR/llm/skills/julia-warm/SKILL.md"              "$TARGET/SKILL.md"
cp "$REPO_DIR/llm/skills/julia-warm/references/"*           "$TARGET/references/"

echo "Installed. Codex will auto-discover this skill in: $PROJECT_DIR"
