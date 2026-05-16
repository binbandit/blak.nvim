---
title: Splash & dashboard
description: The animated black-hole splash that opens Neovim — where it comes from and how to disable it.
---

The splash is the first thing you see on a cold launch of Blak. It's a 66-frame braille animation of a black hole's accretion disc, rendered at 50×14 cells with a red-orange palette. The same animation plays on every dashboard refresh.

## What you're looking at

- **Source**: extracted from the milli.nvim blackhole GIF preview, the same braille frame data milli's `milli export -t lua` produces.
- **Resolution**: 50 columns × 14 rows, each cell a U+2800–U+28FF braille glyph carrying 8 sub-pixels (2×4).
- **Frame rate**: 80 ms per frame (~12.5 fps), 66 frames per loop (~5.3 s).
- **Color**: per-row, per-character color spans (foreground only, transparent background). The palette runs from `#000000` deep into the void to `#ee8822` at the disc's brightest point.

Files:
- Renderer: [`lua/blak/splash/init.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/splash/init.lua)
- Frame data: [`lua/blak/splash/frames/blackhole.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/splash/frames/blackhole.lua) (auto-generated; don't hand-edit)
- Provenance: [`assets/BLACKHOLE_SOURCE.md`](https://github.com/binbandit/blak.nvim/blob/main/assets/BLACKHOLE_SOURCE.md)

## Configuration

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  ui = {
    splash = {
      enabled = true,   -- show the splash at all
      animate = true,   -- play frames; false renders frame 1 statically
      loop = true,      -- loop forever; false plays once and stops
    },
  },
}
```

## Previewing without a cold launch

```vim
:BlakSplash
```

Opens the animation in a scratch buffer. Useful for tuning terminal color rendering, font choice, or letting someone watch it without restarting.

## How it attaches to the dashboard

Snacks owns the dashboard buffer. Blak's splash hooks into two Snacks events:

```lua
-- lua/blak/splash/init.lua
vim.api.nvim_create_autocmd("User", {
  pattern = { "SnacksDashboardOpened", "SnacksDashboardUpdatePost" },
  callback = function() ... end,
})
```

- `SnacksDashboardOpened` — fires once when the dashboard buffer renders. Blak finds frame 1's anchor row and starts the timer.
- `SnacksDashboardUpdatePost` — fires whenever Snacks re-renders the dashboard (resize, action toggle). Blak re-paints so its color extmarks aren't lost.

The animation runs on a `vim.uv.new_timer()`, scheduled with `vim.schedule_wrap`, and is torn down on `BufWipeout` / `BufDelete`.

## Refreshing the frames

The frame file is committed verbatim from upstream milli. To refresh:

1. Replace `lua/blak/splash/frames/blackhole.lua` with the latest copy from [`milli.nvim/lua/milli/splashes/blackhole.lua`](https://github.com/Amansingh-afk/milli.nvim/blob/main/lua/milli/splashes/blackhole.lua).
2. Don't change anything in `lua/blak/splash/init.lua` — it reads the standard milli export shape (`cols`, `rows`, `delays`, `frames`, `colors`).

The static validation script (`scripts/validate.py`) checks frame structure on every CI run: frame count, row/col dimensions, that every glyph is in the braille block, and that color spans are well-formed.

## Disabling completely

```lua
return {
  ui = { splash = { enabled = false } },
}
```

Snacks dashboard still shows; only the animated header is removed. To disable Snacks dashboard entirely, override the Snacks spec — see the [Plugins guide](/blak.nvim/guide/plugins/).
