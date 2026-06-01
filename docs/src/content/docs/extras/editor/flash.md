---
title: Flash Extra
description: Configure editor.flash for label-based jump motions and Treesitter selection.
---

`editor.flash` installs [flash.nvim](https://github.com/folke/flash.nvim) for
label-based jump motions and Treesitter node selection.

This extra deliberately shadows native `s` and `S`. That is an explicit,
opt-in trade and every mapping is visible in `:BlakKeys` — it is never enabled
by default. Flash's `char` mode, which would silently overlay `f`/`t`/`F`/`T`
with jump labels, is **disabled** so the only behavior this extra changes is the
mappings listed below. Nothing happens behind your back.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "editor.flash",
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
| Plugin | `folke/flash.nvim` |
| Keymap | `s` Flash jump (normal, visual, operator) |
| Keymap | `S` Flash Treesitter select (normal, visual, operator) |
| Keymap | `r` Flash remote (operator-pending) |
| Keymap | `R` Flash Treesitter search (operator, visual) |
| Keymap | `<C-s>` toggle Flash while searching (command-line) |

## What gets shadowed

- `s` (substitute character) and `S` (substitute line) in normal and visual
  mode become Flash motions. Use `cl` and `cc` for the native substitutes.
- `r` and `R` are remapped only in operator-pending/visual contexts, so
  normal-mode replace (`r<char>`) and Replace mode (`R`) are untouched.
- `f`, `t`, `F`, `T` stay native — Flash's `char` mode is disabled by default.
- `<C-s>` is mapped only in command-line mode, so it does not clash with Blak's
  core `<C-s>` save mapping. It opts Flash labels into the current `/` search.

## Configure it

Flash options pass through the plugin spec. To opt back into the `f`/`t`/`F`/`T`
labels, re-enable `char` mode in `plugins.specs`:

```lua
return {
  extras = { enabled = { "editor.flash" } },
  plugins = {
    specs = {
      { "folke/flash.nvim", opts = { modes = { char = { enabled = true } } } },
    },
  },
}
```

See the [flash.nvim docs](https://github.com/folke/flash.nvim) for the full
option set.

## Disable it

Remove `"editor.flash"` from `extras.enabled` or run
`:BlakExtras disable editor.flash`, then restart Blak to restore native `s`/`S`,
and run `:BlakExtras sync` to remove the plugin spec.
