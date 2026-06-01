---
title: Git Browse Extra
description: Configure git.gitbrowse to open the current file, line, or repo on the Git remote.
---

`git.gitbrowse` opens the current file, line, or repository on its Git remote
(GitHub, GitLab, Bitbucket, sourcehut) in your browser, using Snacks gitbrowse.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "git.gitbrowse",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable git.gitbrowse
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Keymap | `<leader>gB` opens the current file/line on the remote (normal and visual) |

Snacks already ships with Blak, so this extra adds no plugin spec — it binds a
keymap to `Snacks.gitbrowse()`. In visual mode the selected line range is used,
so the URL points at exactly those lines. The keymap appears in `:BlakKeys`.

The core git blame mapping stays on `<leader>gb`; this extra uses the
uppercase `<leader>gB` for "browse".

## Configure it

Snacks gitbrowse options go under `snacks.gitbrowse`. For example, to open a
permalink (pinned to the current commit) instead of the branch URL:

```lua
return {
  extras = { enabled = { "git.gitbrowse" } },
  snacks = {
    gitbrowse = {
      what = "permalink",
    },
  },
}
```

## Disable it

Remove `"git.gitbrowse"` from `extras.enabled` or run
`:BlakExtras disable git.gitbrowse`, then restart Blak.
