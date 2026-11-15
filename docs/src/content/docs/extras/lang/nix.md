---
title: Nix Extra
description: Configure lang.nix for the nil language server, nixfmt, and Nix Treesitter.
---

`lang.nix` adds Nix support through the `nil` language server with `nixfmt`
formatting. Install `nixfmt` with Nix itself, or add it to your home-manager
packages or a project dev shell:

```sh
nix profile install nixpkgs#nixfmt
```

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
| LSP | `nil_ls` |
| Formatting | `nixfmt` for `nix` |

Mason installs `nil` for `nil_ls`, and Blak starts the server once that
install succeeds. Mason's `nil` package compiles from source, so it needs both
`cargo` and `nix` on `$PATH`. Without them, every launch reports
`failed to install nil_ls` and the details are in `:MasonLog`. Mason's `nixfmt`
package only ships a linux x64 binary, so Blak does not install it. Until
`nixfmt` is on `$PATH`, saving a `.nix` file reports
`Formatters unavailable for nix file` and leaves the buffer as it is.

## Format with alejandra instead

To format with `alejandra` instead of `nixfmt`, install it
(`nix profile install nixpkgs#alejandra`) and override the formatter:

```lua
return {
  extras = { enabled = { "lang.nix" } },
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

Open a `.nix` file and check `:checkhealth vim.lsp` for `nil_ls`.
