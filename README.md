# jw — Julia Warm

Fast Julia test runner and formatter using warm tmux sessions. First run pays the precompilation cost, subsequent runs are near-instant (warm sessions avoid repeated precompilation).

Designed for use by LLM coding agents (Claude Code, Cursor, Copilot, etc.) that need to run Julia tests programmatically. VS Code's TestItemRunner integration requires GUI interaction that agents can't access — `jw` provides the same warm-session speed through a CLI that any tool can call.

## Requirements

- `tmux`
- Julia packages in your test project: `Revise`, `TestEnv`, `TestItemRunner`
- For formatting: `JuliaFormatter`

## Install

```bash
git clone https://github.com/youruser/jw.git
cd jw
./install.sh
```

This symlinks `jw` to `~/.local/bin/`. Pass a custom path: `./install.sh /usr/local/bin`.

**Windows:** Use WSL. Install tmux (`sudo apt install tmux`) and follow the instructions above.

## Usage

```bash
jw start <path>             # Start a warm Julia REPL tab for a package
jw run <path> [filter]      # Run tests (filter by filename substring)
jw output <path|name>       # Show recent output from a tab
jw kill <path|name>         # Kill a tab
jw format [path]            # Format Julia code (default: current dir)
jw attach [repo]            # Attach to the tmux session (infers repo from cwd)
jw list                     # List active tabs
```

`<path>` is a relative or absolute directory containing a `Project.toml`. As a convenience, bare names are looked up under `packages/` if that directory exists.

## How it works

`jw` manages a tmux session (one per git repo) with a window per package. Each window holds a Julia REPL with `Revise`, `TestEnv`, and `TestItemRunner` preloaded. Tests run inside this warm session, skipping all startup and precompilation overhead.

The formatter works the same way — a dedicated window with `JuliaFormatter` loaded, reused across invocations.

Before each test run, `jw` calls `Revise.revise()` and checks `Revise.errors()` — if Revise failed to pick up changes (e.g. syntax errors), it prints a warning suggesting a restart.

## LLM agent setup

Copy `CLAUDE.md.example` into your project's `CLAUDE.md` (or append to an existing one) so Claude Code knows to use `jw` instead of `Pkg.test()`:

```bash
cat /path/to/jw/CLAUDE.md.example >> your-project/CLAUDE.md
```

For other LLM tools, add equivalent instructions to their system prompt or project config.

## Examples

```bash
# Run all tests in a package
jw run packages/MyPackage.jl

# Run only tests whose filename contains "parser"
jw run packages/MyPackage.jl parser

# Format the packages directory
jw format packages/

# Attach to the tmux session to interact with REPLs
jw attach              # infers repo from cwd
jw attach electrons    # explicit repo name

# Check what's running
jw list

# Restart a session (e.g. after struct changes that Revise can't handle)
jw kill MyPackage
jw run packages/MyPackage.jl
```
