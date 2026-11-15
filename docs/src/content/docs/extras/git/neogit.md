---
title: Neogit Extra
description: Configure git.neogit for a Magit-style interactive Git interface.
---

`git.neogit` installs [Neogit](https://github.com/NeogitOrg/neogit), a
Magit-style interactive Git interface with popups for staging, committing,
branching, and rebasing. It pairs with the `git.diffview` extra and uses the
core Snacks picker for menus such as branch checkout.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "git.neogit",
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
| Plugin | `NeogitOrg/neogit` |
| Treesitter | `git_config`, `git_rebase`, `gitcommit`, `diff` |
| Snacks | picker integration enabled |
| Keymap | `<leader>gn` opens Neogit |

Blak does not change the core gitsigns hunk mappings (`<leader>g*`) or the
`git.lazygit` float (`<leader>gg`); Neogit is an additional, complementary Git
surface on `<leader>gn`.

Neogit's diff actions (`d` in the status buffer) need a diff viewer. Enable the
`git.diffview` extra as well and Neogit detects it automatically; without it,
the diff popup only offers `paths`:

```lua
return {
  extras = { enabled = { "git.neogit", "git.diffview" } },
}
```

## Configure it

To change Neogit options, add a matching lazy.nvim spec in `plugins.specs`;
lazy.nvim merges it with the extra's spec, so the Snacks integration stays on.
For example, to open the status buffer in a split instead of a new tab:

```lua
return {
  extras = { enabled = { "git.neogit" } },
  plugins = {
    specs = {
      { "NeogitOrg/neogit", opts = { kind = "split" } },
    },
  },
}
```

## Use it

```vim
:Neogit
```

Disable the extra, restart Blak, then run `:BlakExtras sync` to remove the
plugin spec.
