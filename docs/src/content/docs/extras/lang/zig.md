---
title: Zig Extra
description: Configure lang.zig for the zls language server and Zig Treesitter.
---

`lang.zig` adds Zig support through zls. zls provides formatting with its
built-in `zig fmt`, and Blak's core format config already falls back to the LSP
formatter, so no separate formatter is configured.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.zig",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable lang.zig
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `zig` |
| LSP | `zls` (formatting via `zig fmt`) |

zls installs automatically through Mason.

## Version pinning

zls tracks Zig versions: a tagged Zig release pairs with the matching tagged
zls release. Mason installs tagged zls builds, so if you run Zig nightly you
may need a manually built zls and can point the server's `cmd` at it:

```lua
return {
  extras = { enabled = { "lang.zig" } },
  lsp = {
    servers = {
      zls = {
        cmd = { vim.fn.expand("~/zls/zig-out/bin/zls") },
      },
    },
  },
}
```

## Install and verify

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a `.zig` file and check `:LspInfo` for `zls`.
