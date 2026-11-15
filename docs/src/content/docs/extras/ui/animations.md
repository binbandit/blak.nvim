---
title: Animations Extra
description: Configure ui.animations for Snacks smooth scrolling.
---

`ui.animations` enables Snacks smooth scrolling, leaving the rest of the Blak UI
unchanged.

Snacks' animation helper itself has no on/off option. It is always available,
and other Snacks features animate on their own: indent scope (`ui.indent`) and
dimming (`ui.dim`) animate whether or not this extra is enabled. Use
`vim.g.snacks_animate = false` to turn every Snacks animation off.

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
| Snacks | `scroll.enabled = true` |

## Configure animation speed

Snacks options live under the `snacks` table in `user.lua`. `snacks.animate`
sets the global defaults for every Snacks animation; `snacks.scroll` tunes
smooth scrolling:

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
vim.g.snacks_animate = false       -- every Snacks animation, global
vim.b.snacks_animate = false       -- every Snacks animation, current buffer
vim.g.snacks_scroll = false        -- global smooth scroll
vim.b.snacks_scroll = false        -- current buffer smooth scroll
```

To disable it permanently, remove `"ui.animations"` from `extras.enabled` or run
`:BlakExtras disable ui.animations`.

## Verify it

Restart Blak or reload `user.lua`, then press `<C-d>` in a long file: the view
should glide instead of jumping. `:checkhealth snacks` lists `Snacks.scroll` as
`setup {enabled}`.
