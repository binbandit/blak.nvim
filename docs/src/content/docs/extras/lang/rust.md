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

Your `user.lua` settings win over the extra's defaults for the same keys, so
`["rust-analyzer"] = { check = { command = "check" } }` switches on-save checks
from Clippy back to `cargo check` while keeping `cargo.allFeatures`.

## Cargo.toml and crates.nvim

crates.nvim runs as an in-process language server in `Cargo.toml`, so it uses
the regular LSP keymaps instead of adding its own:

| Key | In `Cargo.toml` |
| --- | --- |
| `K` | Crate popup: description, links, versions |
| `<leader>ca` | Update, upgrade, or expand a crate; open docs, crates.io, or lib.rs |
| Insert mode | Completion for crate names, versions, and features |

Outdated versions show the latest release as virtual text. `:Crates` exposes
every other crates.nvim action, such as `:Crates show_features_popup`.

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

Install Rust itself outside Blak. Formatting and on-save checks use the
toolchain's `rustfmt` and Clippy:

```sh
rustup component add rustfmt clippy
```

Mason installs `rust-analyzer` and `taplo` for the LSP server list, and Mason's
binaries come first on Neovim's `$PATH`, so the Mason `rust-analyzer` is used
even when rustup also has one.

## Debugging

Enable [`debug.dap`](/extras/debug/dap/) as well and `lang.rust` registers
[CodeLLDB](https://github.com/vadimcn/codelldb). Without `debug.dap` it is not
installed; with it, Mason downloads `codelldb` (about 150 MB). The enable order
does not matter.

| With | Contribution |
| --- | --- |
| `debug.dap` | Mason `codelldb`; a `codelldb` adapter |
| `debug.dap` | Launch configuration `Debug binary (cargo build)` |

```lua
return {
  extras = {
    enabled = { "lang.rust", "debug.dap" },
  },
}
```

Run `:BlakExtras sync` after enabling it, and `:restart` if you already started
a debug session in the current session.

`<leader>dc` in a Rust file runs `cargo build` in the file's crate, then debugs
the binary it built, so breakpoints always match the source. A crate or
workspace with several binaries asks which one; a failed build shows its errors
and starts nothing. The program runs from Neovim's working directory, and
Rust's LLDB formatters show `String`, `Vec`, and other standard types by value.

To pass arguments, add a configuration of your own next to Blak's:

```lua
return {
  plugins = {
    specs = {
      {
        "mfussenegger/nvim-dap",
        opts = function(_, opts)
          local blak = opts.configurations.rust[1]
          table.insert(opts.configurations.rust, vim.tbl_extend("force", blak, {
            name = "Debug binary with arguments",
            args = function()
              return require("dap.utils").splitstr(vim.fn.input("Arguments: "))
            end,
          }))
        end,
      },
    },
  },
}
```

Blak does not add a Rust test adapter for `test.neotest`. The only standalone
one, `rouge8/neotest-rust`, is archived and needs `cargo-nextest`; rustaceanvim's
adapter needs rustaceanvim, which replaces Blak's rust-analyzer setup. Run tests
with `cargo test`, or add an adapter yourself as shown in the
[neotest extra](/extras/test/neotest/).

Disabling either extra removes the adapter after `:restart`; Mason keeps
`codelldb` installed until you run `:MasonUninstall codelldb`.

## Install and verify

```vim
:BlakExtras sync
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a Rust file and check `:checkhealth vim.lsp` for `rust_analyzer`.
