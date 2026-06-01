---
title: Nix Extra
description: Configure lang.nix for the nil language server, nixfmt, and Nix Treesitter.
---

`lang.nix` adds Nix support through the `nil` language server with `nixfmt`
formatting.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.nix",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable lang.nix
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `nix` |
| Mason | `nixfmt` |
| LSP | `nil_ls` |
| Formatting | `nixfmt` for `nix` |

`nil_ls` installs automatically through Mason (package `nil`).

## Format with alejandra instead

To format with `alejandra` instead of `nixfmt`, override the formatter:

```lua
return {
  extras = { enabled = { "lang.nix" } },
  mason = { ensure_installed = { "alejandra" } },
  format = {
    formatters_by_ft = {
      nix = { "alejandra" },
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

Open a `.nix` file and check `:LspInfo` for `nil`.
