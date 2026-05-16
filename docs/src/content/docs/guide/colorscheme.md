---
title: Colorscheme
description: The blak colorscheme — pure black surfaces with a small accent palette.
---

The `blak` colorscheme is a black monochrome theme defined in [`lua/blak/theme.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/theme.lua) and exposed through [`colors/blak.lua`](https://github.com/binbandit/blak.nvim/blob/main/colors/blak.lua). It's set as the default via `ui.colorscheme = "blak"`.

Blak uses `folke/tokyonight.nvim` as the palette engine when plugins are available, then preserves the public colorscheme name as `blak`. If TokyoNight is not installed yet, the colorscheme falls back to a small built-in highlight set until `:Lazy sync` installs the full theme adapter.

## Palette

| Token | Hex | Use |
| --- | --- | --- |
| `bg` | `#000000` | Editor background |
| `bg_alt` | `#050505` | Statusline and subtle active-line surfaces |
| `surface` | `#0b0b0b` | Floats and popup menus |
| `surface2` | `#121212` | Highlighted selections and secondary surfaces |
| `border` | `#242424` | Float borders and window separators |
| `fg` | `#f2f2f2` | Normal text |
| `fg_dim` | `#c8c8c8` | Dim foreground text |
| `muted` | `#707070` | Comments and quiet UI text |
| `faint` | `#4a4a4a` | Line numbers and gutters |
| `orange` | `#ff7a18` | Primary heat accent |
| `orange_soft` | `#ff9d2e` | Search and softer accent surfaces |
| `red_orange` | `#ff3d1f` | Errors and hot accents |

## Highlight groups

The full adapter lets TokyoNight derive plugin-specific groups from the Blak palette. The fallback and Blak-owned groups most likely to interest you:

```lua
Normal        fg = #f2f2f2, bg = #000000
NormalFloat   fg = #f2f2f2, bg = #0b0b0b
FloatBorder   fg = #242424, bg = #0b0b0b
CursorLine    bg = #050505
CursorLineNr  fg = #f2f2f2, bold
LineNr        fg = #4a4a4a
SignColumn    bg = #000000
WinSeparator  fg = #242424
Visual        bg = #121212
Search        fg = #000000, bg = #ff9d2e
IncSearch     fg = #000000, bg = #ff7a18
Pmenu         fg = #c8c8c8, bg = #0b0b0b
PmenuSel      fg = #000000, bg = #f2f2f2
Comment       fg = #707070, italic
Function      fg = #f2f2f2, bold
Statement     fg = #ff7a18
PreProc       fg = #ff9d2e
Type          fg = #c8c8c8
Special       fg = #ff7a18
DiagnosticError fg = #ff3d1f
DiagnosticWarn  fg = #ff7a18
BlakAccent    fg = #ff7a18, bold
BlakHot       fg = #ff3d1f, bold
BlakMuted     fg = #707070
```

Diagnostic groups (`DiagnosticError`, `DiagnosticWarn`, `DiagnosticInfo`, `DiagnosticHint`) map to red-orange, orange, dim foreground, and normal foreground respectively.

## Switching themes

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  ui = { colorscheme = "tokyonight" },  -- or any installed scheme
}
```

Blak loads non-`blak` colorschemes through lazy.nvim's `install.colorscheme` chain, with `habamax` as a built-in fallback if the named scheme isn't installed yet (see [`lua/blak/lazy.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/lazy.lua)).

You can also override individual groups in your `user.lua` via an autocmd:

```lua
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "Comment", { fg = "#aaaaaa", italic = false })
  end,
})
```

## Design notes

- **Pure black background.** `#000000` reads as deep black on OLED and matches the splash perfectly. If you find pure black too contrasty, override `Normal` to `#0a0a0a`.
- **One bold accent.** `BlakAccent` is the only color used by Blak's UI chrome beyond the standard groups. The docs site uses the same idea — one ember-red accent on otherwise monochrome surfaces.
- **No italics on identifiers.** Italics are reserved for comments. Function and Type stand out by weight and color, not slant.
