---
title: Neo-tree Extra
description: Configure editor.neotree for the optional Neo-tree sidebar explorer.
---

`editor.neotree` adds Neo-tree as an optional sidebar explorer. It does not
replace Blak's default Oil explorer on `<leader>e`; it adds Neo-tree on
`<leader>E`.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "editor.neotree",
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
| Plugin | `nvim-neo-tree/neo-tree.nvim` on branch `v3.x` |
| Dependencies | `plenary.nvim`, `mini.icons`, `nui.nvim` |
| Keymap | `<leader>E` toggles Neo-tree |
| Defaults | Follow current file and use libuv file watcher |

The keymap appears in `:BlakKeys`.

## user.lua configuration

Opt into the extra:

```lua
return {
  extras = {
    enabled = { "editor.neotree" },
  },
}
```

Oil remains the configured explorer unless you also change explorer settings:

```lua
return {
  explorer = {
    provider = "oil",
  },
  extras = {
    enabled = { "editor.neotree" },
  },
}
```

Blak does not expose a Neo-tree options table in `user.lua`. For a custom
Neo-tree layout, create a local extra with your own `neo-tree.nvim` spec.

## Use it

```vim
<leader>E
:Neotree reveal
```

Disable it with `:BlakExtras disable editor.neotree`, then run
`:BlakExtras sync` and restart.
