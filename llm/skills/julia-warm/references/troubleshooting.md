# Troubleshooting

## tmux not installed

jw requires tmux. If `tmux` is not found:

- **macOS**: `brew install tmux`
- **Ubuntu/Debian**: `sudo apt install tmux`
- **Windows**: Use WSL, then install tmux inside WSL

## Missing Julia packages

jw requires these Julia packages to be available in the project environment or the global environment:

- **For testing**: `Revise`, `TestEnv`, `TestItemRunner`
- **For formatting**: `JuliaFormatter`

Install them in the Julia REPL:

```julia
using Pkg
Pkg.add(["Revise", "TestEnv", "TestItemRunner"])
Pkg.add("JuliaFormatter")  # only needed for jw format
```

If packages are missing, `jw start` or `jw run` will fail during Julia startup with an `ERROR:` message visible in the tmux pane.

## Session scoping

jw creates one tmux session per git repository, named `jw-<repo_basename>`. If not inside a git repo, the session is named `jw-<hostname>`.

Each package within the repo gets its own tmux window within that session. The window name is derived from the directory basename with any `.jl` suffix stripped (tmux uses `.` as a pane separator).

## Timeouts

- **Startup timeout**: 90 seconds for a Julia REPL to become ready (Revise + TestEnv + TestItemRunner loaded)
- **Formatter startup**: 120 seconds for JuliaFormatter to load
- **Test/format execution**: 300 seconds (5 minutes)

If a timeout occurs, jw exits 1 with a timeout message. The tmux window remains open for inspection via `jw output`.

## Monorepo usage

In a monorepo with multiple Julia packages (e.g., under `packages/`), each package gets its own tmux window. Sessions are shared within the repo.

Pass the package directory to jw:

```bash
jw run packages/PackageA.jl
jw run packages/PackageB.jl
```

Both run in separate windows within the same `jw-<repo>` tmux session.

## Sentinel markers in output

Raw tmux pane output may contain internal markers used by jw for synchronization:

- `__JW_READY__` — Julia REPL is ready
- `__JW_DONE__` — Command execution completed
- `__JW_RESULT__:PASS` — Tests/format succeeded
- `__JW_RESULT__:FAIL` — Tests/format failed

These are implementation details. Ignore them when reading test output.

## jw not on PATH

If `jw` is not found, install it:

```bash
cd /path/to/jw
./install.sh
```

This creates a symlink at `~/.local/bin/jw`. Ensure `~/.local/bin` is on your PATH.
