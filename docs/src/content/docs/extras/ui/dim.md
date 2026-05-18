---
title: Dim Extra
description: Configure ui.dim for Snacks active-scope dimming.
---

`ui.dim` enables Snacks dim, which keeps the active scope visually prominent by
dimming the surrounding lines.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "ui.dim",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable ui.dim
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Snacks | `dim.enabled = true` |

Snacks already ships with Blak for dashboard/input/notifier/picker support, so
this extra does not add a plugin spec. Enabling it through `:BlakExtras` applies
it to the current session; if you edit `user.lua`, reload the config or restart
Blak.

## Configure dimming

Snacks dim options go under `snacks.dim`:

```lua
return {
  extras = {
    enabled = { "ui.dim" },
  },
  snacks = {
    dim = {
      scope = {
        min_size = 5,
        max_size = 20,
        siblings = true,
      },
      animate = {
        enabled = true,
        easing = "outQuad",
        duration = { step = 20, total = 300 },
      },
    },
  },
}
```

## Disable dimming temporarily

To keep the extra enabled but disable dimming without editing your enabled
extras list:

```lua
vim.g.snacks_dim = false       -- global
vim.b.snacks_dim = false       -- current buffer
```

You can also call Snacks directly:

```vim
:lua require("snacks").dim.disable()
:lua require("snacks").dim.enable()
```

To disable it permanently, remove `"ui.dim"` from `extras.enabled` or run
`:BlakExtras disable ui.dim`, then restart Blak.
