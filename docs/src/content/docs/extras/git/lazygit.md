---
title: LazyGit Extra
description: Configure git.lazygit for the Snacks LazyGit floating window.
---

`git.lazygit` opens LazyGit inside a Snacks float and wires a discoverable Blak
keymap. It requires the `lazygit` executable to be available in `$PATH`.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "git.lazygit",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable git.lazygit
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Snacks | `lazygit.enabled = true` |
| Keymap | `<leader>gg` opens LazyGit |
| External binary | `lazygit` in `$PATH` |

The keymap appears in `:BlakKeys`.

## Configure LazyGit integration

Snacks LazyGit options go under `snacks.lazygit`:

```lua
return {
  extras = {
    enabled = { "git.lazygit" },
  },
  snacks = {
    lazygit = {
      configure = true,
      config = {
        gui = {
          nerdFontsVersion = "3",
        },
      },
      win = {
        width = 0.95,
        height = 0.95,
      },
    },
  },
}
```

If you maintain your own LazyGit config and do not want Snacks to write its
generated integration config, turn off `configure`:

```lua
return {
  extras = {
    enabled = { "git.lazygit" },
  },
  snacks = {
    lazygit = {
      configure = false,
    },
  },
}
```

## Use it

```vim
<leader>gg
```

Or call Snacks directly:

```vim
:lua require("snacks").lazygit()
```

Run `:checkhealth snacks` or `:BlakDoctor` if the binary is not found.
