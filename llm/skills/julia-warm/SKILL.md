---
name: julia-warm
description: >-
  This skill should be used when the agent needs to "run Julia tests",
  "test a Julia package", "run Pkg.test()", "format Julia code",
  "run JuliaFormatter", or is working in a project containing
  Project.toml files. Provides the jw (Julia Warm) CLI for fast
  test execution and formatting via warm tmux sessions.
---

# Julia Warm (jw)

jw keeps warm Julia REPL sessions in tmux to avoid repeated precompilation. The first run pays the startup cost; subsequent runs are near-instant. Each package gets its own tmux window with Revise, TestEnv, and TestItemRunner preloaded.

## Core Rule

Always use `jw run` to run Julia tests. Never use `julia -e 'using Pkg; Pkg.test()'`, `Pkg.test()`, or `julia --project=@. test/runtests.jl` directly. These cold-start commands are slow and bypass the warm session.

Similarly, always use `jw format` instead of invoking JuliaFormatter via `julia -e ...`.

## Running Tests

```bash
jw run <path>              # Run all tests
jw run <path> <filter>     # Run tests matching filename substring
```

`<path>` is a directory containing a `Project.toml`. Accepts:
- Relative path: `jw run packages/MyPkg.jl`
- Absolute path: `jw run /home/user/project/packages/MyPkg.jl`
- Bare name resolved under `packages/`: `jw run MyPkg.jl`

If no warm session exists for the package, `jw run` starts one automatically. There is no need to call `jw start` first.

### Exit Codes

- **Exit 0**: All tests passed.
- **Exit 1**: Tests failed, threw an exception, or timed out (5 min).

### Interpreting Results

`jw run` prints a summary of test results (Test Summary lines, pass/fail counts).

On exit 1, run `jw output <path>` to capture the full test output (last 100 lines of the tmux pane). Read this output to understand what failed before attempting fixes.

### Filtering Tests

The filter argument is a filename substring passed to TestItemRunner. To run only tests in files containing "parser":

```bash
jw run packages/MyPkg.jl parser
```

## Formatting Code

```bash
jw format [path]    # Defaults to current directory
```

Runs JuliaFormatter on the target directory via a warm session. Exit 0 on success, exit 1 on error.

After formatting, read back modified files to verify the changes are correct.

## Viewing Output

```bash
jw output <path|name>
```

Captures the last ~100 lines from the tmux pane for the given package or window name. Use this to:
- See full test failure details after `jw run` exits 1
- Check formatter output: `jw output formatter`
- Debug startup issues

## When to Restart

Revise auto-recompiles most code changes, but cannot handle:
- Struct definition changes
- Enum changes
- Const changes

Symptoms: `MethodError`, `UndefVarError`, or `WARNING: Revise errors` in output.

To restart, kill the warm session and re-run:

```bash
jw kill <name>
jw run <path>
```

## Listing Sessions

```bash
jw list
```

Shows all active warm sessions and their current state. Useful for diagnostics.

## Additional Resources

### Reference Files

For edge cases, troubleshooting, and advanced usage:
- **`references/troubleshooting.md`** — tmux issues, missing packages, session scoping, timeouts, monorepo usage
