#!/bin/bash
# Automated tests for intercept-julia-test.sh
# Run: bash hooks/scripts/test-intercept.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK="$SCRIPT_DIR/intercept-julia-test.sh"

passed=0
failed=0
total=0

# Create temp dirs
julia_dir=$(mktemp -d)
nonjulia_dir=$(mktemp -d)
touch "$julia_dir/Project.toml"
trap 'rm -rf "$julia_dir" "$nonjulia_dir"' EXIT

assert_exit() {
    local description="$1"
    local expected_exit="$2"
    local cmd="$3"
    local cwd="$4"
    total=$((total + 1))

    local json
    json=$(jq -n --arg cmd "$cmd" --arg cwd "$cwd" \
        '{"tool_input": {"command": $cmd}, "cwd": $cwd}')

    local actual_exit=0
    echo "$json" | bash "$HOOK" >/dev/null 2>/dev/null || actual_exit=$?

    if [ "$actual_exit" -eq "$expected_exit" ]; then
        passed=$((passed + 1))
        echo "  PASS: $description (exit $actual_exit)"
    else
        failed=$((failed + 1))
        echo "  FAIL: $description — expected exit $expected_exit, got $actual_exit"
        echo "        cmd: $cmd"
        echo "        cwd: $cwd"
    fi
}

echo "Running hook tests..."
echo ""

echo "== Should BLOCK (exit 2) =="
assert_exit "Classic Pkg.test()" \
    2 "julia -e 'using Pkg; Pkg.test()'" "$julia_dir"

assert_exit "Scoped Pkg.test with project flag" \
    2 "julia --project=@. -e 'Pkg.test(\"MyPkg\")'" "$julia_dir"

assert_exit "Cold JuliaFormatter" \
    2 "julia -e 'using JuliaFormatter; format(\".\")'" "$julia_dir"

assert_exit "Direct test file execution" \
    2 "julia --project=@. test/runtests.jl" "$julia_dir"

assert_exit "Prefixed with cd" \
    2 "cd foo && julia -e 'Pkg.test()'" "$julia_dir"

echo ""
echo "== Should ALLOW (exit 0) =="
assert_exit "Already using jw" \
    0 "jw run packages/MyPkg" "$julia_dir"

assert_exit "Not Julia (cargo test)" \
    0 "cargo test" "$julia_dir"

assert_exit "Echo, not invocation" \
    0 "echo \"Pkg.test()\"" "$julia_dir"

assert_exit "Julia but not test/format" \
    0 "julia -e 'println(\"hello\")'" "$julia_dir"

assert_exit "Pkg.test but not a Julia project" \
    0 "julia -e 'using Pkg; Pkg.test()'" "$nonjulia_dir"

assert_exit "Unrelated command, non-Julia dir" \
    0 "git status" "$nonjulia_dir"

echo ""
echo "== Results =="
echo "$passed/$total passed, $failed failed"

if [ "$failed" -gt 0 ]; then
    exit 1
fi
exit 0
