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
| Defaults | Follow current file, use libuv file watcher, dialogs follow `ui.winborder` |

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

To change Neo-tree options, add a matching lazy.nvim spec in `plugins.specs`;
lazy.nvim merges it with the extra's spec. For example, to dock it on the right:

```lua
return {
  extras = { enabled = { "editor.neotree" } },
  plugins = {
    specs = {
      { "nvim-neo-tree/neo-tree.nvim", opts = { window = { position = "right" } } },
    },
  },
}
```

## Use it

```vim
<leader>E
:Neotree reveal
```

Disable it with `:BlakExtras disable editor.neotree`, then run
`:BlakExtras sync` and restart.
