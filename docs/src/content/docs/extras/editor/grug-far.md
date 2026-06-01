---
title: Find & Replace Extra
description: Configure editor.grug-far for buffer-based project-wide find and replace.
---

`editor.grug-far` installs
[grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim), a ripgrep-powered
buffer for project-wide find and replace. It fills the gap between Blak's core
grep picker (search only) and the native grep → quickfix → `:cdo` workflow.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "editor.grug-far",
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
| Plugin | `MagicDuck/grug-far.nvim` |
| Keymap | `<leader>sr` opens search and replace |
| Keymap | `<leader>sr` (visual) opens search and replace prefilled with the selection |

Search and replace happen in a normal buffer: edit the search, replace, and
flags fields, preview matches, then apply. Buffer-local actions use
`<localleader>`, so they cannot collide with global mappings. The keymaps
appear in `:BlakKeys`.

## Use it

```vim
:GrugFar
```

Disable the extra, restart Blak, then run `:BlakExtras sync` to remove the
plugin spec.
