---
title: Indent Guides Extra
description: Configure ui.indent for Snacks indent guides with animated scope highlighting.
---

`ui.indent` enables Snacks indent guides, which draw a guide on each indent
level and highlight the active scope with an optional animation.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "ui.indent",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable ui.indent
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Snacks | `indent.enabled = true` |
| Keymap | `<leader>ug` toggles indent guides |

Snacks already ships with Blak for dashboard/input/notifier/picker support, so
this extra does not add a plugin spec — core ships indent disabled and this
flips it on. The keymap appears in `:BlakKeys`.

## Configure the guides

Snacks indent options go under `snacks.indent`:

```lua
return {
  extras = { enabled = { "ui.indent" } },
  snacks = {
    indent = {
      indent = { char = "│" },
      scope = { enabled = true, underline = false },
      animate = { enabled = true, duration = { step = 20, total = 300 } },
    },
  },
}
```

## Disable it

Toggle indent guides for the session with `<leader>ug`. To disable the extra
permanently, remove `"ui.indent"` from `extras.enabled` or run
`:BlakExtras disable ui.indent`, then restart Blak.
