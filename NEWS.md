# Blak news

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
