---
title: Colorscheme
description: Blak uses TokyoNight Night as the default theme.
---

Blak uses [`folke/tokyonight.nvim`](https://github.com/folke/tokyonight.nvim) for its default theme:

```lua
ui = {
  colorscheme = "tokyonight-night",
}
```

There is no Blak palette overlay. TokyoNight owns the colors and plugin highlight groups.

## Native Theme

A first-party Blak theme is still something we want. We tried a bespoke palette, but it was not good enough yet, so Blak ships TokyoNight until a native theme earns its place.

## Switching themes

Set `ui.colorscheme` to another installed colorscheme:

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  ui = { colorscheme = "tokyonight-moon" }, -- or any installed scheme
}
```

Blak loads the configured colorscheme through lazy.nvim's `install.colorscheme` chain, with `habamax` as a built-in last resort if neither the configured scheme nor TokyoNight can load (see [`lua/blak/lazy.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/lazy.lua)).

Theme collections can live in extras. For example, enable Base46 and pick one of its `base46-*` schemes:

```vim
:BlakExtras enable ui.base46
:BlakExtras sync
```

```lua
return {
  ui = { colorscheme = "base46-gruvchad" },
}
```

## TokyoNight Options

If you want to tune TokyoNight itself, pass options through `ui.theme`. Blak forwards this table to `require("tokyonight").setup()` without adding its own palette:

```lua
return {
  ui = {
    colorscheme = "tokyonight-night",
    theme = {
      transparent = true,
      styles = {
        comments = { italic = false },
      },
    },
  },
}
```
