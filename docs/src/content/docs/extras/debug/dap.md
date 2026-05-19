---
title: DAP Extra
description: Configure debug.dap for opt-in Debug Adapter Protocol workflows.
---

`debug.dap` installs [nvim-dap](https://github.com/mfussenegger/nvim-dap) and
[nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui). It provides the client
and UI, but does not guess language adapters or launch configurations.

## Enable it

```lua
return {
  extras = {
    enabled = {
      "debug.dap",
    },
  },
}
```

Because this extra adds plugins, run:

```vim
:BlakExtras sync
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Plugin | `mfussenegger/nvim-dap` |
| Plugin | `rcarriga/nvim-dap-ui` |
| Dependencies | `nvim-nio` |
| Keymap | `<leader>db` toggles a breakpoint |
| Keymap | `<leader>dc` continues debugging |
| Keymap | `<leader>di` steps into |
| Keymap | `<leader>do` steps over |
| Keymap | `<leader>dO` steps out |
| Keymap | `<leader>dr` toggles the DAP REPL |
| Keymap | `<leader>dt` terminates the session |
| Keymap | `<leader>du` toggles dap-ui |

The keymaps appear in `:BlakKeys`.

## Configure adapters

DAP needs an adapter and launch configuration for each language or runtime. Keep
that setup explicit in `user.lua`:

```lua
return {
  extras = {
    enabled = { "debug.dap" },
  },
  hooks = {
    after = {
      function()
        local dap = require("dap")
        dap.configurations.lua = {
          {
            type = "nlua",
            request = "attach",
            name = "Attach to running Neovim instance",
          },
        }
      end,
    },
  },
}
```

Install any external debug adapter with your system package manager, Mason, or a
language-specific Blak extra when one provides it.
