---
title: Claude Code Extra
description: Configure ai.claudecode for Claude Code CLI integration.
---

`ai.claudecode` installs `coder/claudecode.nvim` for Claude Code CLI sessions
inside Blak. It is never enabled by default, and its keymaps are registered
through Blak so they appear in `:BlakKeys`.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "ai.claudecode",
    },
  },
}
```

Because this extra adds a plugin, run:

```vim
:BlakExtras sync
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Plugin | `coder/claudecode.nvim` |
| Dependency | `folke/snacks.nvim` |
| Load trigger | `:ClaudeCode*` commands |
| Defaults | `terminal.provider = "snacks"` |
| Keymap | `<leader>ac` toggles Claude Code |
| Keymap | `<leader>aF` focuses Claude Code |
| Keymap | `<leader>ar` resumes Claude Code |
| Keymap | `<leader>aC` continues Claude Code |
| Keymap | `<leader>am` selects a Claude model |
| Keymap | `<leader>ab` adds the current buffer |
| Keymap | `<leader>as` sends the visual selection |
| Keymap | `<leader>aA` accepts the current diff |
| Keymap | `<leader>aD` denies the current diff |

The keymaps appear in `:BlakKeys`.

## Commands

The plugin also exposes commands for less common actions:

```vim
:ClaudeCode
:ClaudeCodeFocus
:ClaudeCodeOpen
:ClaudeCodeClose
:ClaudeCodeStart
:ClaudeCodeStop
:ClaudeCodeStatus
:ClaudeCodeSelectModel
:ClaudeCodeSend
:ClaudeCodeAdd %
:ClaudeCodeTreeAdd
:ClaudeCodeDiffAccept
:ClaudeCodeDiffDeny
```

## Configure Claude Code

Claude Code options are passed through `ai.claudecode`:

```lua
return {
  extras = {
    enabled = { "ai.claudecode" },
  },
  ai = {
    claudecode = {
      log_level = "info",
      terminal = {
        provider = "snacks",
        split_side = "right",
        split_width_percentage = 0.30,
      },
      diff_opts = {
        layout = "vertical",
      },
    },
  },
}
```

Set `terminal_cmd` if your Claude Code CLI is installed somewhere unusual:

```lua
return {
  extras = {
    enabled = { "ai.claudecode" },
  },
  ai = {
    claudecode = {
      terminal_cmd = vim.fn.expand("~/.claude/local/claude"),
    },
  },
}
```

## Verify it

Install the Claude Code CLI, then run:

```vim
:ClaudeCode
:ClaudeCodeStatus
:BlakDoctor
```

## Disable it

```vim
:BlakExtras disable ai.claudecode
:BlakExtras sync
```

Restart Blak to unload the plugin from the current session.
