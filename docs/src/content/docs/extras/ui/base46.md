---
title: Base46 Extra
description: Configure ui.base46 to install the Base46 colorscheme collection and select a scheme.
---

`ui.base46` installs the Base46 colorscheme collection as optional theme
inventory. It does not change your active colorscheme by itself.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "ui.base46",
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
| Plugin | [`duxlabs-dev/base46`](https://github.com/duxlabs-dev/base46) (formerly `AvengeMedia/base46`) |
| Colorscheme | Base46 `base46-*` schemes |

The plugin loads at startup so the collection shows up in `:colorscheme
base46-<Tab>` completion and colorscheme pickers. Loading it only registers the
schemes; your active colorscheme does not change.

## Pick a Base46 scheme

Set the active scheme with `ui.colorscheme`:

```lua
return {
  extras = {
    enabled = { "ui.base46" },
  },
  ui = {
    colorscheme = "base46-gruvchad",
  },
}
```

Blak loads `ui.colorscheme` during startup. If the scheme cannot be found, Blak
warns and falls back to TokyoNight.

To try a scheme for the current session only, run `:colorscheme base46-<name>`.
Restarting Blak returns to `ui.colorscheme`.

## Theme options

Use Blak's `ui.transparent` option for transparent backgrounds. It works with
every Base46 scheme:

```lua
return {
  extras = {
    enabled = { "ui.base46" },
  },
  ui = {
    colorscheme = "base46-mountain",
    transparent = true,
  },
}
```

Base46's own options (`transparency`, `integrations`, `changed_themes`, and
the rest of its README) go to the plugin spec:

```lua
return {
  extras = {
    enabled = { "ui.base46" },
  },
  plugins = {
    specs = {
      { "duxlabs-dev/base46", opts = { term_colors = false } },
    },
  },
}
```

## Disable it

Remove the extra and choose an installed colorscheme:

```lua
return {
  ui = {
    colorscheme = "tokyonight-night",
  },
  extras = {
    enabled = {},
  },
}
```

Then run `:BlakExtras sync` so lazy.nvim removes the Base46 plugin spec.

See the [colorscheme guide](/guide/colorscheme/) for the broader theme model.
