---
title: Trouble Extra
description: Configure editor.trouble for richer diagnostics, references, symbols, quickfix, and location lists.
---

`editor.trouble` installs [trouble.nvim](https://github.com/folke/trouble.nvim)
as an opt-in list UI for diagnostics, LSP references, symbols, quickfix, and
location list entries. Blak's core diagnostic picker stays unchanged.

## Enable it

```lua
return {
  extras = {
    enabled = {
      "editor.trouble",
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
| Plugin | `folke/trouble.nvim` |
| Dependencies | `mini.icons` |
| Keymap | `<leader>xX` opens diagnostics in Trouble |
| Keymap | `<leader>xQ` opens quickfix in Trouble |
| Keymap | `<leader>xL` opens location list in Trouble |
| Keymap | `<leader>cO` opens symbols in Trouble |
| Keymap | `<leader>cR` opens references in Trouble |

The keymaps appear in `:BlakKeys`.

## Use it

```vim
:Trouble diagnostics
:Trouble qflist
:Trouble loclist
:Trouble symbols
```

Disable the extra, restart Blak, then run `:BlakExtras sync` to remove the
plugin spec.
