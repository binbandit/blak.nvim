# Blak news

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
