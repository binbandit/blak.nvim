---
title: Aerial Extra
description: Configure editor.aerial for an opt-in code outline window.
---

`editor.aerial` installs [aerial.nvim](https://github.com/stevearc/aerial.nvim),
a code outline window powered by LSP and Treesitter symbols.

## Enable it

```lua
return {
  extras = {
    enabled = {
      "editor.aerial",
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
| Plugin | `stevearc/aerial.nvim` |
| Dependencies | `mini.icons` |
| Keymap | `<leader>co` toggles the code outline |

The keymap appears in `:BlakKeys`.

## Use it

```vim
:AerialToggle
:AerialOpen
:AerialNavToggle
```

Aerial uses its own defaults. For deep customization, add an overriding lazy.nvim
spec in `plugins.specs`.
