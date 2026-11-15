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
| Dependencies | `async.nvim` (needed on Neovim 0.12; 0.13 ships `vim.async`) |
| Command | `:Refactor` |
| Keymap | `<leader>re` extracts the selection into a function (visual) |
| Keymap | `<leader>rf` extracts the selection into a function in another file (visual) |
| Keymap | `<leader>rv` extracts the selection into a variable (visual) |
| Keymap | `<leader>ri` inlines the variable under the cursor |
| Keymap | `<leader>rI` inlines the function under the cursor |
| Keymap | `<leader>rp` prints the word under the cursor, or the selection, below it |
| Keymap | `<leader>rc` removes every print-debug statement in the buffer |

The keymaps appear in `:BlakKeys`.

refactoring.nvim requires Neovim 0.12.5 or newer. It uses the Treesitter
parser for the buffer's language, and the inline refactors also need an LSP
server that answers references and definitions. Extract refactors prompt for a
name.

## Use it

```vim
:Refactor inline_var
:Refactor extract_var upper
:Refactor extract_func_to_file helper lua/helpers.lua
```

`:Refactor` runs any refactor by name and completes the names. Extract
refactors act on the last visual selection and take the new name, and for
`extract_func_to_file` the target file, as arguments.
