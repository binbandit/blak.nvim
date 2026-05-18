---
title: Image Preview Extra
description: Configure ui.image-preview for Snacks image support in terminals that support image protocols.
---

`ui.image-preview` enables Snacks image rendering. It can preview image files and
render supported document images in terminals that understand the Kitty graphics
protocol.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "ui.image-preview",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable ui.image-preview
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Snacks | `image.enabled = true` |
| Terminal support | Kitty, Ghostty, WezTerm, and tmux passthrough where available |
| External tools | ImageMagick for conversion of non-PNG formats |

## Configure image rendering

Add Snacks image options under `snacks.image`:

```lua
return {
  extras = {
    enabled = { "ui.image-preview" },
  },
  snacks = {
    image = {
      force = false,
      doc = {
        enabled = true,
        inline = true,
        float = true,
        max_width = 80,
        max_height = 40,
      },
      img_dirs = { "img", "images", "assets", "static", "public" },
    },
  },
}
```

If inline rendering behaves poorly in your terminal, keep previews in floats:

```lua
return {
  extras = {
    enabled = { "ui.image-preview" },
  },
  snacks = {
    image = {
      doc = {
        inline = false,
        float = true,
      },
    },
  },
}
```

## Terminal notes

Snacks can auto-detect supported terminals. If your environment is unusual, set
one of Snacks' environment flags before launching Neovim:

```sh
SNACKS_GHOSTTY=true blak
```

For tmux, make sure passthrough is enabled if images do not display.

## Verify it

Run:

```vim
:checkhealth snacks
:BlakDoctor
```

Then open a PNG or a Markdown file with an image reference.
