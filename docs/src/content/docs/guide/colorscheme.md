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

## Switching themes

Set `ui.colorscheme` to another installed colorscheme:

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  ui = { colorscheme = "tokyonight-moon" }, -- or any installed scheme
}
```

Blak loads the configured colorscheme through lazy.nvim's `install.colorscheme` chain, with `habamax` as a built-in last resort if neither the configured scheme nor TokyoNight can load (see [`lua/blak/lazy.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/lazy.lua)).

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
