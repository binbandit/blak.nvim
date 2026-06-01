---
title: Scratch Extra
description: Configure editor.scratch for Snacks scratch buffers.
---

`editor.scratch` adds Snacks scratch buffers: persistent, context-aware
throwaway notepads keyed by working directory and branch, with auto-save.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "editor.scratch",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable editor.scratch
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Keymap | `<leader>.` toggles a scratch buffer |
| Keymap | `<leader>S` selects from existing scratch buffers |

Snacks already ships with Blak, so this extra adds no plugin spec — it binds
keymaps to `Snacks.scratch()` and `Snacks.scratch.select()`. The keymaps appear
in `:BlakKeys`.

## Configure it

Snacks scratch options go under `snacks.scratch`:

```lua
return {
  extras = { enabled = { "editor.scratch" } },
  snacks = {
    scratch = {
      ft = "markdown",
      autowrite = true,
    },
  },
}
```

## Disable it

Remove `"editor.scratch"` from `extras.enabled` or run
`:BlakExtras disable editor.scratch`, then restart Blak.
