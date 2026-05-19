---
title: Neotest Extra
description: Configure test.neotest as a base for language-specific test adapters.
---

`test.neotest` installs [neotest](https://github.com/nvim-neotest/neotest), an
extensible test runner framework. The extra provides the framework and
discoverable keymaps; language-specific adapters remain explicit user choices.

## Enable it

```lua
return {
  extras = {
    enabled = {
      "test.neotest",
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
| Plugin | `nvim-neotest/neotest` |
| Dependencies | `nvim-nio`, `plenary.nvim`, `FixCursorHold.nvim`, `nvim-treesitter` |
| Keymap | `<leader>Tn` runs the nearest test |
| Keymap | `<leader>Tf` runs the current file |
| Keymap | `<leader>Td` debugs the nearest test through DAP |
| Keymap | `<leader>Ts` toggles the test summary |
| Keymap | `<leader>To` opens test output |
| Keymap | `<leader>TO` toggles the output panel |

The keymaps appear in `:BlakKeys`.

## Add adapters

Neotest needs adapters for your languages. Keep those explicit in `plugins.specs`
so Blak does not install a test stack you did not ask for:

```lua
return {
  extras = {
    enabled = { "test.neotest" },
  },
  plugins = {
    specs = {
      {
        "nvim-neotest/neotest",
        opts = function(_, opts)
          opts.adapters = opts.adapters or {}
          table.insert(opts.adapters, require("neotest-python")({}))
        end,
        dependencies = {
          "nvim-neotest/neotest-python",
        },
      },
    },
  },
}
```

Enable `debug.dap` as well if you want `<leader>Td` to launch tests through the
Debug Adapter Protocol.
