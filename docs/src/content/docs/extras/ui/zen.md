---
title: Zen Extra
description: Configure ui.zen for Snacks zen mode and its Blak keymap.
---

`ui.zen` enables Snacks zen mode for distraction-free editing. It adds one
discoverable keymap and otherwise leaves your normal windows alone.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "ui.zen",
    },
  },
}
```

Or enable it from Neovim:

```vim
:BlakExtras enable ui.zen
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Snacks | `zen.enabled = true` |
| Keymap | `<leader>uz` toggles zen mode |

The keymap appears in `:BlakKeys`.

## Configure zen mode

Snacks zen options go under `snacks.zen`:

```lua
return {
  extras = {
    enabled = { "ui.zen" },
  },
  snacks = {
    zen = {
      toggles = {
        dim = true,
        git_signs = false,
        diagnostics = false,
        inlay_hints = false,
      },
      center = true,
      show = {
        statusline = false,
        tabline = false,
      },
      win = {
        width = 100,
      },
    },
  },
}
```

To keep statusline context visible while focused:

```lua
return {
  extras = {
    enabled = { "ui.zen", "ui.lualine" },
  },
  snacks = {
    zen = {
      show = {
        statusline = true,
      },
    },
  },
}
```

## Use it

```vim
<leader>uz
```

Or call Snacks directly:

```vim
:lua require("snacks").zen()
```

Disable it by removing `"ui.zen"` from `extras.enabled` or running
`:BlakExtras disable ui.zen`.
