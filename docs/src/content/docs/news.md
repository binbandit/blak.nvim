---
title: News
description: What's changing in Blak, release by release.
---

## v0.1.0 — Public preview

Initial implementation. Complete enough to install, use, and share — young enough that issues and contributor feedback are expected.

**Core**

- Native-first Neovim 0.12 config built on `vim.lsp.config()` and `vim.lsp.enable()`.
- `lazy.nvim` package backend with lockfile snapshot/rollback (`:BlakUpdate`, `:BlakRollback`).
- `fff.nvim` as the primary file picker with `snacks` / `telescope` / `fzf-lua` provider fallbacks.
- `blink.cmp` for completion.
- Snacks dashboard, input, notifier, picker, quickfile, bigfile modules.
- Animated black-hole splash extracted from milli.nvim's blackhole GIF preview.
- Conform formatting, nvim-lint linting, native Treesitter.
- Oil as the default file explorer; native terminal split; Gitsigns; Which-key.
- TokyoNight Night as the default colorscheme.

**Extras (reversible)**

- Languages: lua, typescript, typescript-tsgo, python, rust, go, markdown.
- UI: animations, image-preview, zen.
- Git: lazygit, diffview.
- Editor: neotree, snacks-explorer, telescope, fzf-lua.
- AI: copilot.

**Distribution**

- One-command installer that creates a `blak` launcher under `~/.local/bin` and uses `NVIM_APPNAME=blak` so existing Neovim configs are not touched.
- `./dev-install.sh` for local-symlink development.
- CI: static validation + a Neovim smoke test on every push.
- `:BlakTreesitterInstall` helper for parser installation.

This page is the human-readable changelog. Issues, milestones, and discussions live on [the GitHub repo](https://github.com/binbandit/blak.nvim).
