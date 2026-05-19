---
title: Supermaven Extra
description: Configure ai.supermaven for optional Supermaven inline AI completion.
---

`ai.supermaven` installs `supermaven-inc/supermaven-nvim` for inline AI
completion. It is never enabled by default.

Blak disables the plugin's built-in keymaps and registers its own visible
keymaps so they appear in `:BlakKeys`. That keeps the extra opt-in without
quietly taking over `<Tab>`.

## Enable it

```lua
return {
  extras = {
    enabled = {
      "ai.supermaven",
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
| Plugin | `supermaven-inc/supermaven-nvim` |
| Load trigger | `InsertEnter` or `:Supermaven*` |
| Defaults | `disable_keymaps = true`, `log_level = "info"` |
| Keymap | `<leader>aS` toggles Supermaven |
| Keymap | `<M-l>` accepts the inline suggestion |
| Keymap | `<M-w>` accepts one word |
| Keymap | `<M-]>` clears the inline suggestion |

The keymaps appear in `:BlakKeys`.

## Authenticate

After syncing the plugin, start Neovim and run one of:

```vim
:SupermavenUseFree
:SupermavenUsePro
:SupermavenStatus
```

## Configure Supermaven

Supermaven options are passed through `ai.supermaven`:

```lua
return {
  extras = {
    enabled = { "ai.supermaven" },
  },
  ai = {
    supermaven = {
      log_level = "info",
      ignore_filetypes = {
        markdown = true,
      },
    },
  },
}
```

Blak keeps `disable_keymaps = true` even if `ai.supermaven` tries to override
it. Add your own mappings through `keymaps` in `user.lua` if you want different
accept or clear chords.

## Disable it

```vim
:BlakExtras disable ai.supermaven
:BlakExtras sync
```

Restart Blak to unload the plugin and mappings from the current session.
