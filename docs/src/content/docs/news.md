---
title: News
description: What's changing in Blak, release by release.
---

## Unreleased

- Restored Neovim's built-in compressed-file support, tar/zip browsing, and
  Tutor. Blak disables only the netrw directory handler that its explorer
  replaces. See the native-helpers migration for opting out.
- Reload now discards cached plugin options, preserves custom Conform/Blink
  options from `plugins.specs`, removes stale formatter filetypes, and replaces
  removed LSP settings. Live extras refresh their plugin specs before setup.
- `:BlakKeys` now includes mappings in the current buffer, including Blak's
  extras UI and plugin-owned shortcuts.
- Background buffer reads no longer move the visible cursor. Hiding a terminal
  preserves its tab even when it is the last normal window beside a float.

- Fixed false-positive smoke results: failed Lua assertions now return a failing
  exit status. Tests use disposable XDG directories and the committed plugin
  pins, compile all Lua modules, and validate every extra independently.
- Restricted Mason's automatic LSP activation to configured servers, so disabled
  extras stay disabled after restart. `mason.automatic_install = false` now
  covers language servers; `:BlakToolsInstall` explicitly requests both servers
  and tools. Add manually installed servers to `lsp.servers` to auto-enable them.
- Fixed stale leader and LSP mappings on reload, preserved user LSP mapping
  overrides, and prevented `:BlakKeys` from corrupting later registry updates.
  Disabling lint events or shared clipboard now removes the old behavior.
- Rollback now validates every snapshot file before restoring anything; failed
  backups abort updates instead of recording unreadable files as absent.
- Extras preserve explicit LSP and Snacks settings. Reload reuses one plugin-spec
  refresh path and leaves unused formatting plugins deferred. Missing parsers
  no longer replace native indentation, and terminal toggling preserves windows
  reused for editing.
- Installers reject unsafe app names and preserve existing launchers and unrelated
  development symlinks. Installer smoke also checks the current working tree.
- Refreshed 11 plugin pins while retaining Blink's stable `1.*` release policy.
  Updated the documentation stack to Astro 7.3.1, Starlight 0.42.0, and Sharp
  0.35.4; docs development now requires Node.js 22.12+ (CI uses Node.js 24).
  Updated the GitHub Actions checkout, language setup, and Pages actions.
- Corrected the advertised theme and clarified update channels, checkout updates,
  rollback limits, plugin-owned mappings, and retained Mason/parser installations.
  The docs-link validator now checks the actual root-relative routes.
- `:BlakDoctor` no longer reports a broken fff picker as healthy. It probed
  `require("fff")`, which resolves to `fff.main` and defers the Rust backend
  into function bodies, so it succeeded even with no native library on disk.
  The check now probes the backend and names the fix, including the case where
  fff downloaded the library but could not install it over the loaded one and
  left it at `<binary>.tmp`.
- Linting no longer reports failures at the user. A configured linter that is
  not installed is skipped instead of raising `Error running <cmd>: ENOENT` on
  every lint event, and linter output that cannot be parsed is reported once as
  a warning instead of being pinned to line 1 of the buffer as a fake
  diagnostic. `:checkhealth blak` gained a "Linters" section that lists every
  configured linter and whether its binary was found.
- `lang.typescript` and `lang.typescript-tsgo` no longer run `eslint_d`. Both
  extras already enable the ESLint language server, so ESLint diagnostics were
  being produced twice from the same project configuration. Dropping the
  nvim-lint entry removes the duplicate source and the `eslint_d` spawn and
  parse failures that came with it. To keep `eslint_d`, add it back per
  filetype: `lint = { linters_by_ft = { typescript = { "eslint_d" } } }`.
- Re-enabled the built-in `matchparen` and `matchit` plugins. Stock Neovim
  highlights the matching bracket under the cursor and extends `%` matching;
  Blak disabled both for a negligible startup win without replacing them,
  which contradicted the native-first contract. To turn them back off, set
  `vim.g.loaded_matchparen = 1` and `vim.g.loaded_matchit = 1` in a
  `hooks.before` function in `lua/blak/user.lua`.

## v0.3.0 — Fifteen new extras

A batch of opt-in extras that widen language and workflow coverage without
touching any default. Each is reversible and disabled by default.

- **Languages:** `lang.c` (clangd + clang-format), `lang.bash` (bashls +
  shellcheck), `lang.web` (HTML/CSS/Tailwind/Emmet + Prettier), `lang.docker`
  (dockerls + Compose + hadolint), `lang.yaml` and `lang.json` (language servers
  wired to [SchemaStore](https://github.com/b0o/SchemaStore.nvim)),
  `lang.terraform` (terraform-ls + tflint), `lang.nix` (nil + nixfmt), and
  `lang.zig` (zls).
- **Editor:** `editor.flash` for label-based motions (Flash's `char` mode is
  off, so `f`/`t`/`F`/`T` stay native), `editor.grug-far` for project-wide find
  and replace, and `editor.scratch` for Snacks scratch buffers.
- **Git:** `git.gitbrowse` opens the current file or line on the remote, and
  `git.neogit` adds a Magit-style interactive Git interface.
- **UI:** `ui.indent` enables Snacks indent guides with animated scope.
- No default keymaps, picker, completion engine, explorer, or LSP strategy
  changed. The Snacks-backed extras add no new plugins.

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
