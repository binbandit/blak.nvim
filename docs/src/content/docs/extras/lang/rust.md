---
title: Rust Extra
description: Configure lang.rust for rust-analyzer, Taplo, crates.nvim, rustfmt, and Rust/TOML Treesitter support.
---

`lang.rust` adds Rust and TOML editor support. It assumes the Rust toolchain is
managed outside Blak with `rustup` or your system package manager.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.rust",
    },
  },
}
```

Or toggle it from Neovim:

```vim
:BlakExtras enable lang.rust
```

Run `:BlakExtras sync` after enabling because this extra adds a plugin.

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `rust`, `toml` |
| Mason | `codelldb` |
| LSP | `rust_analyzer`, `taplo` |
| Formatting | `rustfmt` with LSP fallback for `rust`; `taplo` with LSP fallback for `toml` |
| Plugins | `saecki/crates.nvim` for `Cargo.toml` |

The extra configures rust-analyzer with `cargo.allFeatures = true` and
`check.command = "clippy"`.

## Configure rust-analyzer

Add non-conflicting rust-analyzer settings in `user.lua`:

```lua
return {
  extras = {
    enabled = { "lang.rust" },
  },
  lsp = {
    servers = {
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            procMacro = { enable = true },
            diagnostics = {
              disabled = { "unresolved-proc-macro" },
            },
          },
        },
      },
    },
  },
}
```

Because extras apply after `user.lua`, the extra's own defaults win if you set
the same exact keys, such as `check.command`. If you need to change those
defaults, make a small local extra or contribute a Blak option for that behavior.

## Configure formatting

The default uses external formatters where available and falls back to LSP:

```lua
return {
  extras = {
    enabled = { "lang.rust" },
  },
  format = {
    formatters_by_ft = {
      rust = { "rustfmt", lsp_format = "fallback" },
      toml = { "taplo", lsp_format = "fallback" },
    },
  },
}
```

## Tooling notes

Install Rust itself outside Blak:

```sh
rustup component add rust-analyzer rustfmt clippy
```

Blak installs `codelldb` through Mason because that tool is editor-facing and
works well as a Mason-managed binary.

## Install and verify

```vim
:BlakExtras sync
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a Rust file and check `:LspInfo` for `rust_analyzer`.
