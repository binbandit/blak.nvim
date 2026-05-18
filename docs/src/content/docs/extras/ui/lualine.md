---
title: Lualine Extra
description: Configure ui.lualine for the optional lualine.nvim statusline.
---

`ui.lualine` replaces Neovim's plain statusline with a small lualine setup. It
keeps ASCII separators, uses lualine's automatic theme detection, and follows
Blak's icon preference.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "ui.lualine",
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
| Plugin | `nvim-lualine/lualine.nvim` |
| Dependency | `nvim-mini/mini.icons` |
| Statusline | Mode, branch, diff, diagnostics, filename, encoding, fileformat, filetype, progress, location |
| Runtime option | Sets `showmode = false` while lualine is active |

## Configure icons

Lualine reads Blak's global icon preference:

```lua
return {
  extras = {
    enabled = { "ui.lualine" },
  },
  ui = {
    icons = false,
  },
}
```

Set `ui.icons = true` or omit it to keep icons enabled.

## Configure theme behavior

The extra uses `theme = "auto"`, so lualine follows the active colorscheme:

```lua
return {
  extras = {
    enabled = { "ui.lualine", "ui.base46" },
  },
  ui = {
    colorscheme = "base46-gruvchad",
  },
}
```

Blak does not expose a separate `lualine` options table in `user.lua`. For a
fully custom statusline layout, create a local extra or fork the extra so the
change stays explicit and reversible.

## Disable it

Remove `"ui.lualine"` from `extras.enabled` or run:

```vim
:BlakExtras disable ui.lualine
:BlakExtras sync
```

Restart Blak to unload the already-started statusline cleanly.
