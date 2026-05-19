---
title: Refactoring Extra
description: Configure editor.refactoring for Treesitter-powered refactor helpers.
---

`editor.refactoring` installs
[refactoring.nvim](https://github.com/ThePrimeagen/refactoring.nvim), a
Treesitter-powered refactoring helper for extracting, inlining, and print-debug
workflows.

## Enable it

```lua
return {
  extras = {
    enabled = {
      "editor.refactoring",
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
| Plugin | `ThePrimeagen/refactoring.nvim` |
| Dependencies | `plenary.nvim`, `nvim-treesitter` |
| Keymap | `<leader>re` extracts a function |
| Keymap | `<leader>rf` extracts a function to a file |
| Keymap | `<leader>rv` extracts a variable |
| Keymap | `<leader>ri` inlines a variable |
| Keymap | `<leader>rI` inlines a function |
| Keymap | `<leader>rp` inserts a print-debug statement |
| Keymap | `<leader>rc` cleans up print-debug statements |

The keymaps appear in `:BlakKeys`.

Most refactors are visual-mode actions because they operate on a selected code
range.
