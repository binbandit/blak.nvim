---
title: Plugins
description: The sixteen plugin specs that ship by default — what they do and why each one is core.
---

Blak ships with sixteen default plugin specs out of the box, plus `lazy.nvim` as the package backend. Reusable optional behavior belongs in an [extra](/guide/extras/); personal plugins can live in `plugins.specs` in `user.lua`.

All base specs live under [`lua/blak/plugins/`](https://github.com/binbandit/blak.nvim/tree/main/lua/blak/plugins).

## UI

### TokyoNight (`folke/tokyonight.nvim`)

Default colorscheme. Blak loads TokyoNight Night without a custom palette or highlight overlay. Loaded eagerly with higher priority than other UI plugins so startup surfaces inherit the final theme.

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

Loaded eagerly only when the splash dashboard is enabled; otherwise it waits until `VeryLazy`. When eager, `priority = 1000` keeps its UI hooks ahead of later plugins. Spec: [`lua/blak/plugins/ui.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/plugins/ui.lua).

### which-key (`folke/which-key.nvim`)

Pops up after the leader (or any prefix) showing the registered keymap groups. Blak pre-registers groups for `b` (buffers), `c` (code), `f` (find), `g` (git), `l` (lazy/blak), `q` (quit), `t` (terminal), `u` (toggles), `w` (windows), `x` (diagnostics). Loaded on `VeryLazy`.

## Editor

### mini.icons (`nvim-mini/mini.icons`)

Icon provider. Mocks `nvim-web-devicons` so plugins expecting that API still work without it. Pinned to `version = false` because the icon set changes frequently.

### mini.pairs (`nvim-mini/mini.pairs`)

Auto-pairs for brackets, quotes, and paired newline insertion. Loaded on `InsertEnter`. This is core because the default editing floor should handle common delimiter insertion without requiring a preference-heavy extra.

### nvim-treesitter (`nvim-treesitter/nvim-treesitter`, `main` branch)

Parser-based syntax, indent, and queries. Configured via [`lua/blak/core/treesitter.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/treesitter.lua). The plugin wakes on `BufReadPre` / `BufNewFile`; parser attachment still happens per-buffer on `FileType` when the line count is below `performance.max_treesitter_lines`. See [Treesitter](/guide/treesitter/).

### nvim-ts-autotag (`windwp/nvim-ts-autotag`)

Auto-closes and renames paired HTML/XML-style tags using Treesitter. Loaded on buffer reads and new files. Blak keeps the slash-close shortcut disabled so normal `/` insertion is not claimed by surprise.

### oil.nvim (`stevearc/oil.nvim`)

The default file explorer when `explorer.provider = "oil"`. Treats directories as buffers you edit. `<leader>e` opens at the current buffer's directory, falling back to the cwd when there is no file. Loaded eagerly so `blak .`, `:edit <directory>`, and Oil's directory takeover behave consistently. Float style: 90 × 90 with rounded border.

## Picker

### fff.nvim (`dmtrKovalenko/fff`)

Default file picker. Native binary backend, downloaded on plugin build. Layout 88 × 82, frecency + history enabled. Registered only when `picker.provider == "fff"` and loaded on first picker use.

See [Pickers](/guide/pickers/) for swapping the backend.

## Completion

### blink.cmp (`saghen/blink.cmp`)

Native completion engine. On the `stable` channel it pins to the `1.*` release; on `edge`/`nightly` it builds from source via `cargo build --release`. Provides LSP, path, snippet, and buffer sources. Ghost text on, documentation auto-show at 250 ms, auto-brackets, rounded borders. The default keymap preset stays `default`; set `completion.super_tab = true` to use blink.cmp's `super-tab` preset. LSP setup registers completion capabilities without loading blink, so the plugin still wakes on `InsertEnter` or `CmdlineEnter`. Spec: [`lua/blak/plugins/completion.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/plugins/completion.lua).

## LSP

### nvim-lspconfig (`neovim/nvim-lspconfig`)

Server configurations only — Blak uses Neovim 0.12's native `vim.lsp.config()` and `vim.lsp.enable()` for the actual wiring. Loaded on `BufReadPre`, `BufNewFile`, or LSP commands so empty dashboard startup avoids LSP cost while the first real file still gets setup before attach. See [LSP](/guide/lsp/).

### mason.nvim (`mason-org/mason.nvim`)

Tool installer. UI border honors `ui.winborder`. Loads on `:Mason`, `VeryLazy`, or as an LSP dependency. Auto-install is controlled by `mason.automatic_install`. See [Mason](/guide/mason/).

### mason-lspconfig.nvim (`mason-org/mason-lspconfig.nvim`)

Bridges Mason package names to lspconfig server names. `ensure_installed` is derived from `lsp.servers` keys. Loads with the first real buffer so Mason-backed LSP enablement is ready before normal editing.

## Formatting & linting

### conform.nvim (`stevearc/conform.nvim`)

Formatter runner. Loads on `BufWritePre`. Format-on-save is gated by `format.enabled` plus the per-buffer / global disable flags (`b:blak_disable_autoformat`, `g:blak_disable_autoformat`). See [Formatting](/guide/formatting/).

### nvim-lint (`mfussenegger/nvim-lint`)

Standalone linter runner. Loads on the events in `lint.events` (default: `BufWritePost`, `BufReadPost`, `InsertLeave`). Silent on missing external tools so it doesn't spam errors when a linter isn't installed yet. See [Linting](/guide/linting/).

## Git

### gitsigns.nvim (`lewis6991/gitsigns.nvim`)

Sign-column git status, hunk navigation, stage / reset / blame. Loaded on `BufReadPre` and `BufNewFile`. Staged signs enabled. Preview border honors `ui.winborder`. See [the git keymaps](/guide/keymaps/#git-gitsigns).

## Why these sixteen

Every plugin here meets one rule from the [philosophy](/guide/philosophy/):

> A feature belongs in core only if most users benefit from it.

A picker, completion, LSP, formatting, linting, treesitter, delimiter/tag pairing, git status, an icon provider, a discoverable keymap menu, and broad highlight coverage for the default theme — that's the floor for "a Neovim editing experience that doesn't feel raw." Everything else lives in an extra.
