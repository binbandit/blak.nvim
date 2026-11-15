---
title: Sidekick Extra
description: Configure ai.sidekick for Sidekick AI CLI terminals and Snacks picker integration.
---

`ai.sidekick` installs `folke/sidekick.nvim` for AI CLI terminals inside Blak.
It is never enabled by default. The extra keeps Copilot Next Edit Suggestions
off unless you opt into them in `user.lua`.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "ai.sidekick",
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
| Plugin | `folke/sidekick.nvim` |
| Defaults | `nes.enabled = false`, `cli.picker = "snacks"` |
| Snacks | Picker action named `sidekick_send` |
| Keymap | `<C-.>` focuses the Sidekick CLI |
| Keymap | `<leader>aa` toggles the CLI |
| Keymap | `<leader>as` selects an AI CLI |
| Keymap | `<leader>ad` detaches the current CLI session |
| Keymap | `<leader>af` sends the current file |
| Keymap | `<leader>at` sends current context |
| Keymap | `<leader>av` sends the visual selection |
| Keymap | `<leader>ap` opens Sidekick prompts |
| Keymap | `<leader>an` jumps to or applies the next edit suggestion |

The keymaps appear in `:BlakKeys`. `<C-.>` needs a terminal that reports
modified keys (Ghostty, Kitty, WezTerm, or tmux with `extended-keys`).
Sending focuses the CLI window; press `<C-.>` to jump back.

## Configure Sidekick

Sidekick options are passed through `ai.sidekick`:

```lua
return {
  extras = {
    enabled = { "ai.sidekick" },
  },
  ai = {
    sidekick = {
      nes = { enabled = false },
      cli = {
        picker = "snacks",
      },
    },
  },
}
```

Enable a CLI multiplexer if you want Sidekick sessions to run through tmux:

```lua
return {
  extras = {
    enabled = { "ai.sidekick" },
  },
  ai = {
    sidekick = {
      cli = {
        mux = {
          enabled = true,
          backend = "tmux",
        },
      },
    },
  },
}
```

## Enable Next Edit Suggestions

Blak defaults `nes.enabled` to `false` so the extra stays a terminal-based AI
workflow until you ask for inline edit suggestions. NES needs the Copilot
language server, so enable [`ai.copilot`](/extras/ai/copilot/) too and sign in
with `:LspCopilotSignIn`:

```lua
return {
  extras = {
    enabled = { "ai.sidekick" },
  },
  ai = {
    sidekick = {
      nes = {
        enabled = true,
      },
    },
  },
}
```

With NES enabled, Sidekick loads at startup instead of on first use. Press
`<leader>an` to jump to a suggestion, then again to apply it. `<Esc>` clears it.

## Add a picker send key

The extra registers the Snacks picker action `sidekick_send`, but it does not
bind a picker-local key for you. Add one in `user.lua` if you want to send picker
items to Sidekick:

```lua
return {
  extras = {
    enabled = { "ai.sidekick" },
  },
  snacks = {
    picker = {
      win = {
        input = {
          keys = {
            ["<a-a>"] = { "sidekick_send", mode = { "n", "i" } },
          },
        },
      },
    },
  },
}
```

## Verify it

Install at least one Sidekick-supported AI CLI. Use `<leader>as` to select a CLI
and `<leader>aa` to open it, then run:

```vim
:checkhealth sidekick
:BlakDoctor
```

Sidekick loads on first use, so `:checkhealth sidekick` reports "No healthcheck
found" until you press a Sidekick key or run `:Sidekick`. Its
`No Copilot LSP server is enabled` error only matters for NES; the CLI features
work without Copilot.
