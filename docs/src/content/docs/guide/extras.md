---
title: Extras
description: Every Blak extra, what it ships, and the contract for writing your own.
---

Extras are how Blak says "yes" to language support, optional tools, and personal preference — without bloating core for everyone.

All extras live under [`lua/blak/extras/`](https://github.com/binbandit/blak.nvim/tree/main/lua/blak/extras), registered in [`lua/blak/extras/init.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/extras/init.lua).

## The contract

An extra is a single Lua module that can contribute any of:

- Treesitter parsers (`ensure_installed`)
- Mason tools (`mason.ensure_installed`)
- LSP servers via `vim.lsp.config()`
- Formatters and linters by filetype
- Snacks module options
- Keymaps (auto-shown in `:BlakKeys`)
- Plugin specs for lazy.nvim

When you disable an extra and restart, Blak stops registering that extra's plugin specs, keymaps, tools, parsers, and config contributions. Run `:BlakExtras sync` afterward to let lazy.nvim clean up removed plugins.

## Managing extras

```vim
:BlakExtras list                  " show available + which are enabled
:BlackExtras list                 " same command, typo-friendly
:BlakExtras enable lang.rust
:BlakExtras disable git.lazygit
:BlakExtras sync                  " run :Lazy sync after changes
```

State persists outside the repo in `stdpath('state')/blak/extras.json`. That means:

- A fresh clone with the same `NVIM_APPNAME` reuses the same enabled extras.
- A fresh install under a new `NVIM_APPNAME` starts from your config defaults.
- Multiple checkouts (`blak`, `blak-dev`) can have different enabled sets.
- `user.lua` and `extras.json` compose: anything in `extras.enabled` in `user.lua` is added on top of the state file.

If an extra was renamed or removed, `:BlakDoctor` reports it as unknown. Run `:BlakExtras disable <id>` to remove that stale state entry.

After enabling an extra:

1. Blak applies its config to the current session.
2. **Run `:BlakExtras sync` or `:Lazy sync`** if plugins were added.
3. **Run `:BlakToolsInstall`** to install any new Mason tools required.
4. **Run `:BlakDoctor`** to confirm everything resolved.

After disabling an extra, the state file updates immediately. Restart Blak when you want already-loaded plugins, keymaps, and runtime hooks to disappear from the current session, then run `:BlakExtras sync` if plugin specs were removed.

## Languages

### `lang.lua`

Lua development — what Blak itself is written in.

| Adds | Value |
| --- | --- |
| Treesitter | `lua`, `luadoc` |
| Mason | `stylua` |
| LSP | `lua_ls` |
| Format | `stylua` for `.lua` |

### `lang.typescript`

TypeScript and JavaScript with ESLint + Prettier.

| Adds | Value |
| --- | --- |
| Treesitter | `javascript`, `typescript`, `tsx`, `jsdoc`, `json`, `jsonc` |
| Mason | `prettier`, `prettierd`, `eslint_d` |
| LSP | `ts_ls`, `eslint` |
| Format | `prettierd` (fallback `prettier`) for js/ts/jsx/tsx/json |
| Lint | `eslint_d` for js/ts/jsx/tsx |

### `lang.python`

Python with Pyright + Ruff + Black + isort.

| Adds | Value |
| --- | --- |
| Treesitter | `python` |
| Mason | `black`, `isort`, `ruff` |
| LSP | `pyright`, `ruff` |
| Format | `isort`, then `black` |
| Lint | `ruff` |

### `lang.rust`

Rust with rust-analyzer and TOML support.

| Adds | Value |
| --- | --- |
| Treesitter | `rust`, `toml` |
| Mason | `codelldb` |
| LSP | `rust_analyzer` (with `cargo.allFeatures` + Clippy), `taplo` |
| Format | `rustfmt` (LSP fallback), `taplo` (LSP fallback) |
| Plugins | `saecki/crates.nvim` |

### `lang.go`

Go with gopls and golangci-lint.

| Adds | Value |
| --- | --- |
| Treesitter | `go`, `gomod`, `gosum`, `gowork` |
| Mason | `goimports`, `gofumpt`, `golangci-lint` |
| LSP | `gopls` |
| Format | `goimports`, `gofumpt` |
| Lint | `golangcilint` |

### `lang.markdown`

Markdown with Marksman LSP and Prettier.

| Adds | Value |
| --- | --- |
| Treesitter | `markdown`, `markdown_inline` |
| Mason | `prettier`, `prettierd`, `markdownlint` |
| LSP | `marksman` |
| Format | `prettierd` (fallback `prettier`) for markdown |
| Lint | `markdownlint` |

## UI

### `ui.animations`

Smooth scroll and cursor animations via Snacks.

| Adds | Value |
| --- | --- |
| Snacks | `animate.enabled = true`, `scroll.enabled = true` |

### `ui.base46`

[AvengeMedia/base46](https://github.com/AvengeMedia/base46), the NvChad Base46 colorscheme collection as regular Neovim colorschemes.

| Adds | Value |
| --- | --- |
| Plugin | `AvengeMedia/base46` |

Enable the extra, sync plugins, then set `ui.colorscheme` to a Base46 scheme such as `base46-gruvchad`.

### `ui.image-preview`

Image previews in pickers and floats — works in Kitty, WezTerm, and Ghostty.

| Adds | Value |
| --- | --- |
| Snacks | `image.enabled = true` |

### `ui.zen`

Distraction-free editing mode.

| Adds | Value |
| --- | --- |
| Snacks | `zen.enabled = true` |
| Keymap | `<leader>uz` → toggle zen |

## Git

### `git.lazygit`

LazyGit floating window via Snacks.

| Adds | Value |
| --- | --- |
| Snacks | `lazygit.enabled = true` |
| Keymap | `<leader>gg` → LazyGit float |

Requires `lazygit` in `$PATH`.

### `git.diffview`

[sindrets/diffview.nvim](https://github.com/sindrets/diffview.nvim) for richer diffs and file history.

| Adds | Value |
| --- | --- |
| Plugin | `sindrets/diffview.nvim` |
| Keymap | `<leader>gD` → `:DiffviewOpen` |
| Keymap | `<leader>gH` → file history |

## AI

### `ai.copilot`

GitHub Copilot integration via [zbirenbaum/copilot.lua](https://github.com/zbirenbaum/copilot.lua).

| Adds | Value |
| --- | --- |
| Plugin | `zbirenbaum/copilot.lua` |

> Never enabled by default. Opt in with `:BlakExtras enable ai.copilot`.

## Editor

### `editor.neotree`

[nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) as an alternative file explorer alongside Oil.

| Adds | Value |
| --- | --- |
| Plugin | `nvim-neo-tree/neo-tree.nvim` (v3.x) |
| Deps | `plenary.nvim`, `mini.icons`, `nui.nvim` |
| Keymap | `<leader>E` → toggle Neo-tree |

### `editor.snacks-explorer`

[Snacks explorer](https://github.com/folke/snacks.nvim/blob/main/docs/explorer.md) as the configured file explorer.

| Adds | Value |
| --- | --- |
| Config | sets `explorer.provider = "snacks"` |
| Snacks | `explorer.enabled = true` |
| Mason | `fd` |
| Keymap | `<leader>e` → Snacks explorer |

Snacks already ships in core for dashboard/input/notifier/picker support, so this extra enables the explorer module instead of adding a new plugin.

### `editor.telescope`

[nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) as the picker backend.

| Adds | Value |
| --- | --- |
| Plugin | `nvim-telescope/telescope.nvim` |
| Deps | `plenary.nvim`, `mini.icons` |
| Config | sets `picker.provider = "telescope"` |

Enabling this swaps `:BlakPick` and all `<leader>f*` mappings to Telescope.

### `editor.fzf-lua`

[ibhagwan/fzf-lua](https://github.com/ibhagwan/fzf-lua) as the picker backend.

| Adds | Value |
| --- | --- |
| Plugin | `ibhagwan/fzf-lua` |
| Deps | `mini.icons` |
| Config | sets `picker.provider = "fzf_lua"` |

## Anatomy of an extra

```lua
-- lua/blak/extras/lang/rust.lua
return {
  id = "lang.rust",
  label = "Rust",
  description = "rust-analyzer + treesitter",
  treesitter = { "rust", "toml" },
  mason = { "codelldb" },
  lsp = {
    servers = {
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = { check = { command = "clippy" } },
        },
      },
    },
  },
  format = {
    formatters_by_ft = { rust = { lsp_format = "fallback" } },
  },
  keys = {
    { lhs = "<leader>cc", rhs = ":!cargo check<CR>", desc = "cargo check" },
  },
  plugins = { -- optional, lazy.nvim spec list
    { "owner/plugin.nvim", opts = {} },
  },
  apply = function(config) -- optional, runs after merge
    config.snacks.dim = { enabled = true }
  end,
}
```

That's the entire surface. See [Writing an extra](/project/writing-extras/) for the full guide.
