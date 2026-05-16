---
title: Plugins
description: The thirteen plugin specs that ship by default — what they do and why each one is core.
---

Blak ships with thirteen default plugin specs out of the box, plus `lazy.nvim` as the package backend. Anything beyond this list is an [extra](/guide/extras/).

All base specs live under [`lua/blak/plugins/`](https://github.com/binbandit/blak.nvim/tree/main/lua/blak/plugins).

## UI

### Snacks (`folke/snacks.nvim`)

Modules enabled by default:

| Module | Purpose |
| --- | --- |
| `dashboard` | Start screen, hosts the Blak splash header |
| `bigfile` | Disables heavy features for files > `performance.bigfile_size` |
| `quickfile` | Faster opening for the first buffer |
| `input` | Replaces `vim.ui.input` with a floating prompt |
| `notifier` | Replaces `vim.notify` with stacked toasts |
| `picker` | Picker backend (used unless you swap to telescope / fzf_lua) |
| `words` | Highlights other occurrences of the word under cursor |

Loaded with `priority = 1000` so its UI hooks beat other plugins. Spec: [`lua/blak/plugins/ui.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/plugins/ui.lua).

### which-key (`folke/which-key.nvim`)

Pops up after the leader (or any prefix) showing the registered keymap groups. Blak pre-registers groups for `b` (buffers), `c` (code), `f` (find), `g` (git), `l` (lazy/blak), `q` (quit), `t` (terminal), `u` (toggles), `x` (diagnostics). Loaded on `VeryLazy`.

## Editor

### mini.icons (`nvim-mini/mini.icons`)

Icon provider. Mocks `nvim-web-devicons` so plugins expecting that API still work without it. Pinned to `version = false` because the icon set changes frequently.

### nvim-treesitter (`nvim-treesitter/nvim-treesitter`, `main` branch)

Parser-based syntax, indent, and queries. Configured via [`lua/blak/core/treesitter.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/treesitter.lua). Lazy-loaded per-buffer on `FileType` when the buffer line count is below `performance.max_treesitter_lines`. See [Treesitter](/guide/treesitter/).

### oil.nvim (`stevearc/oil.nvim`)

The default file explorer. Treats directories as buffers you edit. `<leader>e` opens at the current buffer's directory, falling back to the cwd when there is no file. Loaded eagerly so `blak .`, `:edit <directory>`, and Oil's directory takeover behave consistently. Float style: 90 × 90 with rounded border.

## Picker

### fff.nvim (`dmtrKovalenko/fff`)

Default file picker. Native binary backend, downloaded on plugin build. Layout 88 × 82, frecency + history enabled. Only loaded when `picker.provider == "fff"`.

See [Pickers](/guide/pickers/) for swapping the backend.

## Completion

### blink.cmp (`saghen/blink.cmp`)

Native completion engine. On the `stable` channel it pins to the `1.*` release; on `edge`/`nightly` it builds from source via `cargo build --release`. Provides LSP, path, snippet, and buffer sources. Ghost text on, documentation auto-show at 250 ms, auto-brackets, rounded borders. Spec: [`lua/blak/plugins/completion.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/plugins/completion.lua).

## LSP

### nvim-lspconfig (`neovim/nvim-lspconfig`)

Server configurations only — Blak uses Neovim 0.12's native `vim.lsp.config()` and `vim.lsp.enable()` for the actual wiring. Loaded eagerly so LSP is available immediately. See [LSP](/guide/lsp/).

### mason.nvim (`mason-org/mason.nvim`)

Tool installer. UI border honors `ui.winborder`. Auto-install controlled by `mason.automatic_install`. See [Mason](/guide/mason/).

### mason-lspconfig.nvim (`mason-org/mason-lspconfig.nvim`)

Bridges Mason package names to lspconfig server names. `ensure_installed` is derived from `lsp.servers` keys.

## Formatting & linting

### conform.nvim (`stevearc/conform.nvim`)

Formatter runner. Loads on `BufWritePre`. Format-on-save is gated by `format.enabled` plus the per-buffer / global disable flags (`b:blak_disable_autoformat`, `g:blak_disable_autoformat`). See [Formatting](/guide/formatting/).

### nvim-lint (`mfussenegger/nvim-lint`)

Standalone linter runner. Loads on the events in `lint.events` (default: `BufWritePost`, `BufReadPost`, `InsertLeave`). Silent on missing external tools so it doesn't spam errors when a linter isn't installed yet. See [Linting](/guide/linting/).

## Git

### gitsigns.nvim (`lewis6991/gitsigns.nvim`)

Sign-column git status, hunk navigation, stage / reset / blame. Loaded on `BufReadPre` and `BufNewFile`. Staged signs enabled. Preview border honors `ui.winborder`. See [the git keymaps](/guide/keymaps/#git-gitsigns).

## Why these thirteen

Every plugin here meets one rule from the [philosophy](/guide/philosophy/):

> A feature belongs in core only if most users benefit from it.

A picker, completion, LSP, formatting, linting, treesitter, git status, an icon provider, a discoverable keymap menu — that's the floor for "a Neovim editing experience that doesn't feel raw." Everything else lives in an extra.
