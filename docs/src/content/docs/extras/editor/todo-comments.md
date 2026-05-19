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

The keymaps appear in `:BlakKeys`.

## Use it

```vim
:TodoQuickFix
:TodoLocList
:TodoTrouble
:TodoTelescope
:TodoFzfLua
:TodoSnacks
```

Some commands depend on the matching picker or Trouble plugin also being
available. `:TodoQuickFix` works without enabling another Blak extra.
