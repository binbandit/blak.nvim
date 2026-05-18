---
title: Diffview Extra
description: Configure git.diffview for richer Git diffs and file history.
---

`git.diffview` adds `diffview.nvim` for reviewing file changes, branch diffs,
and file history in a dedicated interface.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "git.diffview",
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
| Plugin | `sindrets/diffview.nvim` |
| Command | `:DiffviewOpen` |
| Command | `:DiffviewFileHistory` |
| Keymap | `<leader>gD` opens Diffview |
| Keymap | `<leader>gH` opens file history for the current file |

The keymaps appear in `:BlakKeys`.

## Common workflows

Open the current working tree diff:

```vim
:DiffviewOpen
```

Compare the current branch to `main`:

```vim
:DiffviewOpen main...HEAD
```

Inspect the current file's history:

```vim
<leader>gH
```

## user.lua configuration

The Blak extra intentionally keeps Diffview's plugin options at their defaults.
Your `user.lua` only needs to opt into the extra:

```lua
return {
  extras = {
    enabled = { "git.diffview" },
  },
}
```

For a custom Diffview setup, make a local extra that adds your preferred
`diffview.nvim` lazy.nvim spec. That keeps the preference reversible and avoids
hiding a workflow change in core config.

## Disable it

```vim
:BlakExtras disable git.diffview
:BlakExtras sync
```

Restart Blak to unload already-registered commands and keymaps from the current
session.
