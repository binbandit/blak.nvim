# Blak news

## Unreleased

- Re-enabled the built-in `matchparen` and `matchit` plugins. Stock Neovim
  highlights the matching bracket under the cursor and extends `%` matching;
  Blak disabled both for a negligible startup win without replacing them,
  which contradicted the native-first contract. To turn them back off, set
  `vim.g.loaded_matchparen = 1` and `vim.g.loaded_matchit = 1` in a
  `hooks.before` function in `lua/blak/user.lua`.

## v0.3.0

Fifteen new opt-in extras, all reversible and disabled by default. No default
keymaps, picker, completion engine, explorer, or LSP strategy changed.

- Languages: `lang.c` (clangd, clang-format), `lang.bash` (bashls, shellcheck),
  `lang.web` (HTML/CSS/Tailwind/Emmet), `lang.docker` (dockerls, Compose,
  hadolint), `lang.yaml` and `lang.json` (language servers wired to SchemaStore
  schemas), `lang.terraform` (terraform-ls, tflint), `lang.nix` (nil, nixfmt),
  and `lang.zig` (zls).
- Editor: `editor.flash` (label-based jump motions; `f`/`t` stay native),
  `editor.grug-far` (project-wide find and replace), and `editor.scratch`
  (Snacks scratch buffers).
- Git: `git.gitbrowse` (open the current file or line on the remote) and
  `git.neogit` (Magit-style interactive Git).
- UI: `ui.indent` (Snacks indent guides with animated scope).
- The Snacks-backed extras (`ui.indent`, `git.gitbrowse`, `editor.scratch`) add
  no new plugins.

## v0.2.2

Maintenance release that refreshes the bundled plugin pins:

- Updated the lazy lockfile, bumping `conform.nvim`, `fff`, `lazy.nvim`,
  `mason.nvim`, `mini.icons`, `nvim-lint`, `nvim-lspconfig`, `oil.nvim`, and
  `snacks.nvim` to their latest tracked commits.
- No default keymaps, pickers, completion, explorer, or LSP strategy changed.
  Muscle memory is preserved; this is purely a dependency refresh.

## v0.2.1

Patch release for two default editing fixes:

- Switched core pair handling from `mini.pairs` to `nvim-autopairs` so pressing
  Enter inside braces creates the expected block shape with the closing brace on
  its own line.
- Made `<Space><Space>` a plain file finder instead of a duplicate "smart"
  picker surface. `:BlakPick smart` still works as a compatibility alias for
  `files`.
- Updated picker, Mini extra, and keymap docs to describe the shipped behavior,
  and added smoke coverage for brace-newline insertion and picker dispatch.

## v0.2.0

This release turns the first public preview into a more complete daily-driver
shape: extras are easier to inspect and change, updates have a clearer trust
contract, configuration is more explicit, and the documentation now covers the
runtime in detail.

Highlights:

- Added `:BlakExtras`, a browsable extras UI, live extras activation, and
  refresh-on-change support for `lua/blak/user.lua`.
- Added many reversible extras: Claude Code, Sidekick, Supermaven, DAP,
  Neotest, Harpoon, Trouble, Aerial, Overseer, Refactoring, todo-comments,
  render-markdown, mini modules, Snacks terminal/explorer, window navigation,
  lualine, dim, comfy line numbers, Base46, and TypeScript tsgo.
- Added `:BlakDocs`, expanded `<Space>l` management keymaps, native split
  keymaps, alternate-file toggle, and function-valued user keymaps.
- Added typed config metadata, schema validation, string completions, and a
  richer `lua/blak/user.example.lua`.
- Added `blak.theme`, transparent theme support, and the TokyoNight adapter
  while keeping the default theme plain and inspectable.
- Added config-aware update and upgrade guards so `:BlakUpdate` stays within
  the accepted channel and `:BlakUpgrade` handles deliberate migrations.
- Switched the public installer to a sparse runtime checkout with a launcher,
  and hardened install, rollback, and smoke-test coverage.
- Deferred more plugin and config startup work so common paths wake only when
  needed.
- Expanded README, Vim help, keymap docs, command docs, default/schema
  references, validation notes, and every shipped extra's docs page.

Fixes:

- Restored local file discovery in the fff picker provider.
- Refreshed user keymaps on reload and blink super-tab mappings after config
  changes.
- Smoothed Snacks explorer quit behavior and splash recentering after explorer
  close.
- Stopped the Snacks explorer extra from installing `fd` unexpectedly.
- Stabilized CI smoke tests and expanded release/install validation.

## v0.1.0

Initial implementation:

- Native-first Neovim 0.12 config
- fff.nvim primary file picker with provider fallbacks
- Snacks dashboard with animated black-hole splash
- blink.cmp completion
- Native LSP via `vim.lsp.config()` and Mason integration
- Conform formatting and nvim-lint linting
- Reversible extras framework
- Config-aware rollback snapshots and explicit upgrade migrations

- `:BlakTreesitterInstall` parser installation helper
- Public installer targets `binbandit/blak.nvim` and creates a `blak` launcher
