---
title: Neogit Extra
description: Configure git.neogit for a Magit-style interactive Git interface.
---

`git.neogit` installs [Neogit](https://github.com/NeogitOrg/neogit), a
Magit-style interactive Git interface with popups for staging, committing,
branching, and rebasing. It pairs with the `git.diffview` extra and uses the
core Snacks picker for menus.

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
| Dependencies | `plenary.nvim` |
| Treesitter | `git_config`, `git_rebase`, `gitcommit`, `diff` |
| Snacks | picker integration enabled |
| Keymap | `<leader>gn` opens Neogit |

Blak does not change the core gitsigns hunk mappings (`<leader>g*`) or the
`git.lazygit` float (`<leader>gg`); Neogit is an additional, complementary Git
surface on `<leader>gn`. When the `git.diffview` extra is also enabled, Neogit
auto-detects it for diffs.

## Configure it

Neogit options pass through the plugin spec; override them in `plugins.specs`
if you need to. For example, to enable the diffview integration explicitly:

```lua
return {
  extras = { enabled = { "git.neogit", "git.diffview" } },
}
```

## Use it

```vim
:Neogit
```

Disable the extra, restart Blak, then run `:BlakExtras sync` to remove the
plugin spec.
