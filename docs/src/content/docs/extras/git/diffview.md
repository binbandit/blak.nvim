---
title: Diffview Extra
description: Configure git.diffview for richer Git diffs and file history.
---

`git.diffview` adds [diffview-plus.nvim](https://github.com/dlyongemallo/diffview-plus.nvim)
for reviewing file changes, branch diffs, and file history in a dedicated
interface. It is the maintained fork of `sindrets/diffview.nvim`, which has had
no commits since June 2024; commands and the `diffview` module are unchanged,
so Neogit's diffview integration keeps working. Blak follows its tagged
releases.

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
| Plugin | `dlyongemallo/diffview-plus.nvim` (tagged releases) |
| Dependency | `mini.icons` for file icons |
| Command | `:DiffviewOpen`, `:DiffviewClose`, `:DiffviewToggle` |
| Command | `:DiffviewFileHistory`, `:DiffviewDiffFiles`, `:DiffviewLog` |
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

To change Diffview options, add a matching lazy.nvim spec in `plugins.specs`;
lazy.nvim merges it with the extra's spec:

```lua
return {
  extras = { enabled = { "git.diffview" } },
  plugins = {
    specs = {
      { "dlyongemallo/diffview-plus.nvim", opts = { enhanced_diff_hl = true } },
    },
  },
}
```

## Disable it

```vim
:BlakExtras disable git.diffview
:BlakExtras sync
```

Restart Blak to unload already-registered commands and keymaps from the current
session.
