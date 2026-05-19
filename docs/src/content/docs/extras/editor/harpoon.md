---
title: Harpoon Extra
description: Configure editor.harpoon for Harpoon v2 file marks and quick navigation.
---

`editor.harpoon` installs [Harpoon v2](https://github.com/ThePrimeagen/harpoon/tree/harpoon2)
and calls `require("harpoon"):setup({})`, which Harpoon requires for its
autocmds and persistence hooks.

## Enable it

```lua
return {
  extras = {
    enabled = {
      "editor.harpoon",
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
| Plugin | `ThePrimeagen/harpoon` on branch `harpoon2` |
| Dependencies | `plenary.nvim` |
| Setup | `require("harpoon"):setup({})` |
| Keymap | `<leader>ha` adds the current file |
| Keymap | `<leader>hh` toggles the Harpoon quick menu |
| Keymap | `<leader>hp` / `<leader>hn` jumps previous / next |
| Keymap | `<leader>h1` through `<leader>h4` jumps to marked files |

The keymaps appear in `:BlakKeys`.

## Use it

```vim
<leader>ha
<leader>hh
<leader>h1
```

The quick menu is Harpoon's editable list UI. Change lines there to reorder,
remove, or add targets, then close it normally.

## Configure Harpoon

Blak keeps Harpoon on its upstream defaults. To pass setup options, add a
matching lazy.nvim spec in `plugins.specs`; lazy.nvim merges it with the extra's
plugin spec:

```lua
return {
  extras = {
    enabled = { "editor.harpoon" },
  },
  plugins = {
    specs = {
      {
        "ThePrimeagen/harpoon",
        opts = {
          settings = {
            save_on_toggle = true,
            sync_on_ui_close = true,
          },
        },
      },
    },
  },
}
```

## Disable it

```vim
:BlakExtras disable editor.harpoon
:BlakExtras sync
```

Restart Blak to unload mappings and runtime hooks that already ran in the
current session.
