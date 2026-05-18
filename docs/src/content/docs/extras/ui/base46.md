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
| Plugin | `AvengeMedia/base46` |
| Colorscheme | Base46 `base46-*` schemes |

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

## Theme options

Blak passes `ui.theme` to colorschemes that expose a Lua `setup()` function.
Base46 schemes are plain colorschemes, so use Blak's `ui.transparent` option
for transparent backgrounds:

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
