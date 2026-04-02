---
description: Run jw (Julia Warm) commands for Julia test running and formatting
allowed-tools: Bash(jw *)
argument-hint: <run|start|output|kill|format|list> [path] [filter]
---

# Context

Check if jw is available:
!`which jw 2>/dev/null || echo "NOT_FOUND"`

# Task

Run the jw command with the provided arguments:

```
jw $ARGUMENTS
```

If jw is not found on PATH, instruct the user to install it:

1. Clone the jw repository
2. Run `./install.sh` from the jw repo directory
3. Ensure `~/.local/bin` is on their PATH

After running the command, display the output. If the exit code is non-zero, explain what went wrong based on the output.

For `jw run` with exit code 1: tests failed. Run `jw output <path>` to show full failure details.
For `jw format` with exit code 1: formatting failed. Run `jw output formatter` for details.
