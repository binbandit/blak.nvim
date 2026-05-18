---
title: Mini.nvim Modules Extra
description: Configure editor.mini for selected nvim-mini modules.
---

`editor.mini` installs and sets up the Mini modules you list in `mini.modules`.
It uses the standalone `nvim-mini/mini.<module>` repositories instead of
pulling in the whole collection, and it does not enable any module by default.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "editor.mini",
    },
  },
  mini = {
    modules = {
      "ai",
      "surround",
      "pairs",
      "splitjoin",
    },
    opts = {
      surround = { n_lines = 80 },
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
| Plugin | `nvim-mini/mini.<module>` for every configured module except `icons` |
| Config | `require("mini.<module>").setup(opts)` |

`mini.icons` already ships in Blak core. Keep it out of `mini.modules` unless
you are intentionally replacing the core icon setup in your own fork.

## Choose modules

Use module slugs without the `mini.` prefix:

```lua
return {
  extras = { enabled = { "editor.mini" } },
  mini = {
    modules = { "ai", "move", "surround", "trailspace" },
  },
}
```

`mini.ai` also works if you prefer the full module name.

Common choices:

| Module | Adds |
| --- | --- |
| `ai` | richer `a`/`i` textobjects |
| `surround` | add, delete, replace, and find surrounds |
| `pairs` | autopairs |
| `splitjoin` | split and join arguments |
| `trailspace` | highlight and remove trailing whitespace |
| `hipatterns` | highlight configured text patterns |

The upstream module list lives in the
[mini.nvim documentation](https://nvim-mini.org/mini.nvim/doc/mini-nvim.html#mini.nvim-module-list).

## Configure a module

Options go under `mini.opts.<module>` and are passed directly to that module's
`setup()` call:

```lua
return {
  extras = { enabled = { "editor.mini" } },
  mini = {
    modules = { "surround", "pairs" },
    opts = {
      surround = {
        n_lines = 120,
      },
      pairs = {
        modes = {
          insert = true,
          command = false,
          terminal = false,
        },
      },
    },
  },
}
```

Many Mini modules create their own mappings or commands during `setup()`.
Blak keeps the selection explicit in `user.lua` so enabling this extra does not
silently change editing behavior.

## Disable it

Remove `"editor.mini"` from `extras.enabled` or run:

```vim
:BlakExtras disable editor.mini
:BlakExtras sync
```

Restart Blak when you want already-loaded Mini modules, mappings, and runtime
hooks to disappear from the current session.
