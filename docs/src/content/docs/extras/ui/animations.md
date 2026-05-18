---
title: Animations Extra
description: Configure ui.animations for Snacks animate and smooth scroll support.
---

`ui.animations` enables the optional Snacks animation layer. It turns on the
general animation helper and smooth scrolling, leaving the rest of the Blak UI
unchanged.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "ui.animations",
    },
  },
}
```

You can also enable it from Neovim:

```vim
:BlakExtras enable ui.animations
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Snacks | `animate.enabled = true` |
| Snacks | `scroll.enabled = true` |

## Configure animation speed

Snacks options live under the `snacks` table in `user.lua`. The extra supplies
`enabled = true`; you can add the detailed options beside it:

```lua
return {
  extras = {
    enabled = { "ui.animations" },
  },
  snacks = {
    animate = {
      duration = 20,
      easing = "linear",
      fps = 120,
    },
    scroll = {
      animate = {
        duration = { step = 10, total = 200 },
        easing = "linear",
      },
      animate_repeat = {
        delay = 100,
        duration = { step = 5, total = 50 },
        easing = "linear",
      },
    },
  },
}
```

## Disable animations temporarily

To keep the extra installed but turn off animations for a session or a buffer,
use Snacks' runtime flags:

```lua
vim.g.snacks_animate = false       -- global
vim.b.snacks_animate = false       -- current buffer
vim.g.snacks_scroll = false        -- global smooth scroll
vim.b.snacks_scroll = false        -- current buffer smooth scroll
```

To disable it permanently, remove `"ui.animations"` from `extras.enabled` or run
`:BlakExtras disable ui.animations`.

## Verify it

Restart Blak or reload `user.lua`, then scroll a long file. `:BlakDoctor` will
also report whether Snacks loaded cleanly.
