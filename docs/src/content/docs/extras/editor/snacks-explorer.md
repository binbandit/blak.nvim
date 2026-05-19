---
title: Snacks Explorer Extra
description: Configure editor.snacks-explorer as the Blak file explorer provider.
---

`editor.snacks-explorer` switches Blak's configured explorer from Oil to Snacks.
After enabling it, `<leader>e` and the dashboard Explorer action open or close
Snacks explorer.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "editor.snacks-explorer",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable editor.snacks-explorer
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Config | `explorer.provider = "snacks"` |
| Snacks | `explorer.enabled = true`; explorer picker `auto_close = true` |
| Keymap | `<leader>e` toggles Snacks explorer instead of opening Oil |
| External binary | `fd` is recommended for fast file discovery |

The retargeted keymap appears in `:BlakKeys`.
Blak also toggles an already-open Snacks explorer instead of opening a second one.

## Configure explorer behavior

General Snacks explorer options go under `snacks.explorer`:

```lua
return {
  extras = {
    enabled = { "editor.snacks-explorer" },
  },
  snacks = {
    explorer = {
      replace_netrw = true,
      trash = true,
    },
  },
}
```

The explorer is also a Snacks picker source. Configure its picker behavior under
`snacks.picker.sources.explorer`:

```lua
return {
  extras = {
    enabled = { "editor.snacks-explorer" },
  },
  snacks = {
    picker = {
      sources = {
        explorer = {
          auto_close = false,
          hidden = true,
          ignored = false,
          layout = {
            layout = {
              position = "right",
            },
          },
        },
      },
    },
  },
}
```

## Switch back to Oil

Remove the extra or disable it:

```vim
:BlakExtras disable editor.snacks-explorer
```

If you set the provider manually, set it back:

```lua
return {
  explorer = {
    provider = "oil",
  },
  extras = {
    enabled = {},
  },
}
```

Restart Blak when you want already-loaded explorer hooks to disappear cleanly.
