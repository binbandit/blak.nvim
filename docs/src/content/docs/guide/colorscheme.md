---
title: Colorscheme
description: The blak colorscheme — pure black surfaces with a small accent palette.
---

The `blak` colorscheme is a small, hand-written colorscheme defined in [`colors/blak.lua`](https://github.com/binbandit/blak.nvim/blob/main/colors/blak.lua). It's set as the default via `ui.colorscheme = "blak"`.

## Palette

| Token | Hex | Use |
| --- | --- | --- |
| `bg` | `#000000` | Editor background |
| `bg2` | `#090909` | Floats, NormalFloat, CursorLine |
| `bg3` | `#111111` | Statusline, Pmenu, alt surfaces |
| `fg` | `#d8d8d8` | Normal text |
| `dim` | `#7a7a7a` | Comments |
| `muted` | `#555555` | LineNr, NC statusline, dim chrome |
| `accent` | `#f1f1f1` | CursorLineNr, Function, PmenuSel |
| `red` | `#ff6b6b` | Errors |
| `orange` | `#f5a97f` | Special, IncSearch |
| `yellow` | `#eed49f` | Warnings, Search, Todo |
| `green` | `#a6da95` | Strings |
| `cyan` | `#8bd5ca` | Type, hints |
| `blue` | `#8aadf4` | Statements, info |
| `purple` | `#c6a0f6` | Constants, PreProc |

## Highlight groups

The colorscheme sets 32 groups. The ones most likely to interest you:

```lua
Normal        fg = #d8d8d8, bg = #000000
NormalFloat   fg = #d8d8d8, bg = #090909
FloatBorder   fg = #555555, bg = #090909
CursorLine    bg = #090909
CursorLineNr  fg = #f1f1f1, bold
LineNr        fg = #555555
SignColumn    bg = #000000
StatusLine    fg = #d8d8d8, bg = #111111
StatusLineNC  fg = #555555, bg = #090909
WinSeparator  fg = #111111
Visual        bg = #252525
Search        fg = #000000, bg = #eed49f
IncSearch     fg = #000000, bg = #f5a97f
Pmenu         fg = #d8d8d8, bg = #090909
PmenuSel      fg = #000000, bg = #f1f1f1
Comment       fg = #7a7a7a, italic
Constant      fg = #c6a0f6
String        fg = #a6da95
Function      fg = #f1f1f1, bold
Statement     fg = #8aadf4
PreProc       fg = #c6a0f6
Type          fg = #8bd5ca
Special       fg = #f5a97f
Error         fg = #ff6b6b
Todo          fg = #000000, bg = #eed49f, bold
BlakAccent    fg = #f1f1f1, bold
```

Diagnostic groups (`DiagnosticError`, `DiagnosticWarn`, `DiagnosticInfo`, `DiagnosticHint`) map to red, yellow, blue, cyan respectively.

## Switching themes

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  ui = { colorscheme = "tokyonight" },  -- or any installed scheme
}
```

Blak loads the colorscheme through lazy.nvim's `install.colorscheme` chain, with `habamax` as a built-in fallback if the named scheme isn't installed yet (see [`lua/blak/lazy.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/lazy.lua)).

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
