---
title: News
description: What's changing in Blak, release by release.
---

## v0.2.2 — Dependency refresh

A maintenance release that refreshes the bundled plugin pins without adding
configuration weight or changing any defaults.

- The lazy lockfile was updated, bumping `conform.nvim`, `fff`, `lazy.nvim`,
  `mason.nvim`, `mini.icons`, `nvim-lint`, `nvim-lspconfig`, `oil.nvim`, and
  `snacks.nvim` to their latest tracked commits.
- No default keymaps, picker, completion engine, explorer, or LSP strategy
  changed. Muscle memory is preserved — this is purely a dependency refresh.

## v0.2.1 — Editing defaults polish

This patch release tightens two default editing surfaces without adding new
configuration weight.

- Pair handling now uses `nvim-autopairs`, which gives the expected brace block
  shape when pressing Enter inside `{}`.
- `<Space><Space>` is now documented and implemented as a plain file finder
  instead of a duplicate "smart" picker. `:BlakPick smart` remains available as
  a compatibility alias for `files`.
- Docs and smoke coverage were updated for pair insertion, picker dispatch, and
  the Mini extra's non-conflicting module guidance.

## v0.2.0 — Extras, updates, and docs

Blak's second preview release is the first one that feels shaped for regular use rather than just first install. Extras are discoverable, configuration reloads are safer, updates have a clearer trust contract, and the docs now describe the runtime instead of merely introducing it.

**Core**

- `:BlakExtras` opens a browsable extras UI, and extras can now be enabled, disabled, synced, and activated live.
- `lua/blak/user.lua` auto-refreshes more predictably, including user keymaps and function-valued mappings.
- `:BlakDocs` opens the docs site from inside Neovim.
- New management keymaps live under `<Space>l`; native split maps and alternate-file toggling were added.
- Configuration now has typed metadata, schema validation, string completions, and a richer `lua/blak/user.example.lua`.
- Startup work is deferred across plugin and config setup so common paths load less up front.

**Updates**

- `:BlakUpdate` now enforces the accepted channel and blocks pending breaking migrations.
- `:BlakUpgrade` handles deliberate migrations and workflow-affecting moves.
- Rollback, install, and smoke-test paths were hardened.
- The public installer now creates a sparse runtime checkout with the runtime files Blak actually needs.

**Theme**

- `blak.theme` centralizes theme loading.
- TokyoNight now goes through a theme adapter.
- Transparent editor backgrounds can be enabled with `ui.transparent`.
- The default theme stays plain `tokyonight-night`.

**Extras**

- AI: Claude Code, Sidekick, Supermaven.
- Debug/test: DAP and Neotest.
- Editor: Aerial, Harpoon, mini modules, Overseer, Refactoring, render-markdown, Snacks explorer, Snacks terminal, todo-comments, Trouble, window navigation.
- UI: Base46, comfy line numbers, dim, lualine.
- Language: TypeScript tsgo, plus Rust crates.nvim support.

**Fixes**

- Restored local file discovery in the fff picker provider.
- Refreshed blink super-tab mappings after config changes.
- Smoothed Snacks explorer quit behavior and splash recentering.
- Stopped the Snacks explorer extra from installing `fd` unexpectedly.
- Stabilized CI smoke tests.

## v0.1.0 — Public preview

Initial implementation. Complete enough to install, use, and share — young enough that issues and contributor feedback are expected.

**Core**

- Native-first Neovim 0.12 config built on `vim.lsp.config()` and `vim.lsp.enable()`.
- `lazy.nvim` package backend with config-aware rollback snapshots (`:BlakUpdate`, `:BlakUpgrade`, `:BlakRollback`).
- `fff.nvim` as the primary file picker with `snacks` / `telescope` / `fzf-lua` provider fallbacks.
- `blink.cmp` for completion.
- Snacks dashboard, input, notifier, picker, quickfile, bigfile modules.
- Animated black-hole splash extracted from milli.nvim's blackhole GIF preview.
- Conform formatting, nvim-lint linting, native Treesitter.
- Oil as the default file explorer; native terminal split; Gitsigns; Which-key.
- TokyoNight Night as the default colorscheme.

**Extras (reversible)**

- Languages: lua, typescript, typescript-tsgo, python, python-pro, rust, go, markdown.
- UI: animations, image-preview, zen.
- Git: lazygit, diffview.
- Editor: neotree, snacks-explorer, telescope, fzf-lua.
- AI: copilot, sidekick.

**Distribution**

- One-command installer that creates a `blak` launcher under `~/.local/bin` and uses `NVIM_APPNAME=blak` so existing Neovim configs are not touched.
- `./dev-install.sh` for local-symlink development.
- CI: static validation + a Neovim smoke test on every push.
- `:BlakTreesitterInstall` helper for parser installation.

This page is the human-readable changelog. Issues, milestones, and discussions live on [the GitHub repo](https://github.com/binbandit/blak.nvim).
