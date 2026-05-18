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

In Blak docs, theme settings live here: `ui.colorscheme` picks the active
colorscheme, `ui.transparent` asks Blak to clear editor backgrounds after the
scheme loads, and `ui.theme` passes setup options to the active colorscheme
when that colorscheme exposes a Lua `setup()` function.

There is no Blak palette overlay. The active colorscheme owns the colors and
plugin highlight groups.

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

## Transparent Background

Set `ui.transparent = true` when you want the terminal background to show
through the main editor UI:

```lua
return {
  ui = {
    colorscheme = "base46-mountain",
    transparent = true,
  },
}
```

Blak applies this with native highlight APIs after the colorscheme loads, so it
works with TokyoNight, Base46 schemes, and other installed colorschemes. Some
plugins may still own their own shaded surfaces.

## Theme Options

If you want to tune the colorscheme itself, pass options through `ui.theme`.
Blak tries to call the theme module's `setup()` before loading the colorscheme:

```lua
return {
  ui = {
    colorscheme = "catppuccin-mocha",
    theme = {
      transparent_background = true,
      integrations = { gitsigns = true },
    },
  },
}
```

Blak tries the colorscheme name first, then the name before the final dash. For
example, `tokyonight-night` can configure `require("tokyonight").setup(...)`.
If the theme does not expose an inferable setup module, configure it where the
plugin is installed instead:

```lua
return {
  plugins = {
    specs = {
      { "owner/my-theme.nvim", opts = { style = "dark" } },
    },
  },
  ui = { colorscheme = "my-theme-dark" },
}
```

That keeps Blak's theme contract small while still letting custom plugins use
their own setup rules.
