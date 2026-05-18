---
title: Window Navigation Extra
description: Configure editor.window-navigation for Ctrl-h/j/k/l window movement.
---

`editor.window-navigation` adds normal-mode Ctrl-h/j/k/l window movement using
Neovim's native `:wincmd`.

It is opt-in because `<C-l>` is stock Neovim's redraw key. Enabling this extra
is an explicit choice to trade that native mapping for faster pane movement.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "editor.window-navigation",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable editor.window-navigation
```

No plugin sync is required.

## What it adds

| Surface | Contribution |
| --- | --- |
| Keymap | `<C-h>` moves to the window on the left |
| Keymap | `<C-j>` moves to the window below |
| Keymap | `<C-k>` moves to the window above |
| Keymap | `<C-l>` moves to the window on the right |

The keymaps appear in `:BlakKeys`.

## Scope

The mappings are normal-mode only. Blak does not bind them in terminal mode, so
shell shortcuts such as Ctrl-k and Ctrl-l stay with the terminal.

## Disable it

```vim
:BlakExtras disable editor.window-navigation
```

Restart Blak to unload keymaps that were already registered in the current
session.
