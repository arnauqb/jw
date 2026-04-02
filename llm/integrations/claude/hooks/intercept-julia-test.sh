#!/bin/bash
# PreToolUse hook: intercepts slow-path Julia test/format commands
# and blocks them with a suggestion to use jw instead.
#
# Input: JSON on stdin with tool_input.command and cwd
# Output: stderr message + exit 2 to block, or exit 0 to allow
set -euo pipefail

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')

# No command or cwd — allow through
if [ -z "$cmd" ] || [ -z "$cwd" ]; then
    exit 0
fi

# Stage 1: Does the command invoke julia as a command word?
# Match "julia" at start of line or after a shell operator (; && || |)
if ! echo "$cmd" | grep -qE '(^|[;&|]+\s*)julia\s'; then
    exit 0
fi

# Stage 2: Is this a slow-path test or format invocation?
is_test=false
is_format=false

if echo "$cmd" | grep -qE 'Pkg\.test\(|Pkg\.test"|test/runtests\.jl'; then
    is_test=true
elif echo "$cmd" | grep -qE 'JuliaFormatter|format\('; then
    is_format=true
fi

if [ "$is_test" = false ] && [ "$is_format" = false ]; then
    exit 0
fi

# Stage 3: Scope check — walk up from cwd looking for Project.toml
pkg_dir=""
dir="$cwd"
while [ "$dir" != "/" ]; do
    if [ -f "$dir/Project.toml" ]; then
        pkg_dir="$dir"
        break
    fi
    dir=$(dirname "$dir")
done

if [ -z "$pkg_dir" ]; then
    exit 0
fi

# Stage 4: Build suggestion
if [ "$is_test" = true ]; then
    suggestion="jw run $pkg_dir"
else
    suggestion="jw format $pkg_dir"
fi

# Stage 5: Block with message
cat >&2 <<EOF
BLOCKED: Use jw instead of running Julia directly.

  $suggestion

jw keeps warm Julia sessions — much faster than cold starts.
EOF
exit 2
