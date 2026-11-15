---
title: TODO Comments Extra
description: Configure editor.todo-comments for highlighted and searchable TODO-style comments.
---

`editor.todo-comments` installs
[todo-comments.nvim](https://github.com/folke/todo-comments.nvim) to highlight
and collect `TODO`, `FIX`, `HACK`, `NOTE`, and related comment markers.

## Enable it

```lua
return {
  extras = {
    enabled = {
      "editor.todo-comments",
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
| Plugin | `folke/todo-comments.nvim` |
| Dependencies | `plenary.nvim` |
| Keymap | `]t` jumps to the next TODO comment |
| Keymap | `[t` jumps to the previous TODO comment |
| Keymap | `<leader>xT` opens TODO comments in the quickfix list |

The keymaps appear in `:BlakKeys`. `]t` and `[t` replace Neovim's default
tag-list mappings (`:tnext` / `:tprevious`); those commands still work, and
`]T` / `[T` keep their default `:tlast` / `:tfirst` behavior.

## Use it

```vim
:TodoQuickFix
:TodoLocList
:lua Snacks.picker.todo_comments()
:TodoTrouble
:TodoTelescope
:TodoFzfLua
```

`:TodoQuickFix`, `:TodoLocList`, and the Snacks picker work without enabling
another Blak extra. The Snacks picker source is registered when the plugin
loads, which happens when you open a file; the `:Todo*` commands load it on
demand. `:TodoTrouble`, `:TodoTelescope`, and `:TodoFzfLua` need
`editor.trouble`, `editor.telescope`, or `editor.fzf-lua`. Each command accepts
`cwd=` and `keywords=` filters, for example `:TodoQuickFix keywords=TODO,FIX`.
