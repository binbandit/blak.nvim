# Blak news

## v0.4.0

Every extra was tested end to end in a real editor, and the broken ones were
fixed. Blak now uses more of Neovim 0.12 directly. Plugins install at shipped
pins, including extras, and your lockfile moved out of the checkout.

### Before you update

- Your lockfile now lives at `stdpath('state')/blak/lazy-lock.json`, so
  `:BlakUpdate` no longer modifies the checkout. If `git pull --ff-only`
  refuses because of local changes to `lazy-lock.json`, run
  `git -C ~/.config/blak checkout lazy-lock.json` and pull again. On the next
  start Blak records the commits you have installed, so no plugin moves.
- Run `:BlakUpgrade` after updating. It explains each change below that
  affects you.
- Blak no longer maps `gr`, `gI` and `K` in LSP buffers. Neovim's `grr`
  (references), `gri` (implementation) and `K` (hover) cover them. Bare `gr`
  used to wait for `timeoutlen` because it shadowed Neovim's `gr` prefix.
  `]d`/`[d` are Neovim's own jumps now, so counts work and `[D`/`]D` reach the
  first and last diagnostic; the float still opens after each jump. To restore
  `gr`, add `{ key = "gr", action = vim.lsp.buf.references, desc = "References" }`
  to `keymaps`.
- `ai.supermaven` was removed because the Supermaven service shut down. Use
  `ai.copilot`.

### Pins and updates

- `lazy-lock.json` in the checkout now holds shipped pins for every plugin
  that core or any extra can install. A plugin is first installed at the
  commit Blak was tested with. Your own updates and rollbacks always win.
  `editor.mini` modules, which you choose, follow their default branch.
  Maintainers refresh pins with `make pins`, and `make validate` fails for
  plugins without one.
- `:BlakExtras sync` installs and cleans at pinned commits and no longer
  updates every installed plugin, which `:Lazy sync` did.
- `:BlakRollback` right after `:BlakUpdate` in the same session restored
  nothing and wrote the post-update pins back. It now restores the snapshot.
  Rollback also prefers the full snapshot over a legacy lockfile backup taken
  in the same second.
- A fresh install no longer modifies the lockfile on first launch. Blak starts
  lazy.nvim at its pinned commit instead of the newest stable tag.
- Refreshed core and extra plugin pins. Updated the documentation stack to
  Astro 7.4.12 and Starlight 0.43.1, with no known vulnerabilities.

### Native Neovim

- Language servers in `lsp.servers` start through `vim.lsp.enable()`, so
  servers installed outside Mason (Nix, Homebrew, Xcode) work. A missing binary
  is only logged.
- Removed the `:LspInfo`-style lazy-load stubs, which do nothing on Neovim
  0.12. Use `:checkhealth vim.lsp` and `:lsp`.
- Neovim defaults are back: `smartindent` is no longer enabled (it moved `#`
  comment lines to column 0 in files without an indent expression),
  `jumpoptions` keeps `clean` and adds `view`, and `completeopt` keeps `popup`.
  Removed settings that only repeated Neovim's defaults. `grepprg` is set only
  when `rg` is installed.
- The completion menu, documentation, signature and diagnostic float borders
  follow `ui.winborder`.
- Restart hints point at `:restart`. Replaced deprecated API calls and removed
  fallbacks for Neovim versions older than 0.12.

### Core fixes

- The first file you open is now linted on open, not only after a save.
- Enabling an extra and running `:BlakExtras sync` loads its plugins in the
  same session, including plugins that load on `VeryLazy`.
- Mason install failures now warn and point at `:MasonLog`. `:checkhealth blak`
  checks that Mason tools and enabled extras' plugins are installed.
- Without a StyLua config, StyLua formats Lua with Blak's indent settings
  (spaces by default) instead of tabs.
- Snacks pickers show file icons. which-key names the `<leader>a`, `d`, `h`,
  `o`, `r`, `s` and `T` groups that extras use.
- `:BlakKeys` lists Ctrl-key mappings in the Blak section, and reload removes
  them. Git hunk mappings in Visual mode no longer apply in Select mode.
- `:Lazy` no longer draws a frame around the whole editor. Long notifications
  wrap. The notification history has no line numbers.
- The splash keeps its colors after `:colorscheme`. `:BlakSplash` opens a
  centered float, and the dashboard hides `~` rows and the ruler.
- `ui.theme` reaches base46 for scheme names with several dashes.
- CI checks Lua formatting with StyLua, and the advisory nightly smoke passes
  again on Neovim 0.13 development builds.

### Extras

- `ai.copilot` showed no suggestions as configured. It now uses
  copilot-language-server with Neovim's native inline completion: sign in
  with `:LspCopilotSignIn`, accept with `<M-l>`, cycle with `<M-]>`/`<M-[>`.
  Existing sign-ins carry over.
- `git.diffview` uses `dlyongemallo/diffview-plus.nvim`, the maintained fork.
  Commands and keymaps are unchanged.
- `debug.dap` and `test.neotest` work out of the box with a language extra:
  `lang.go` adds Delve and neotest-golang, `lang.python` and `lang.python-pro`
  add debugpy and neotest-python, and `lang.rust` adds codelldb, which it now
  installs only when `debug.dap` is enabled. dap-ui shows a session that
  started before it opened. neotest dropped unneeded dependencies and warns
  when no adapter exists.
- Fixed `editor.refactoring` for the rewritten upstream plugin (needs Neovim
  0.12.5+), `editor.overseer` for overseer v2, and `editor.render-markdown`'s
  toggle.
- `lang.tailwind` and `lang.web` start Tailwind only in Tailwind projects.
  HTML and CSS hovers are readable. `lang.typescript` no longer mixes position
  encodings.
- `lang.bash` no longer reports shellcheck twice. `lang.terraform` lints
  through tflint's language server, so diagnostics land on the right line.
  `lang.nix` no longer installs nixfmt through Mason, which only supports
  Linux x64. `lang.rust` enables crates.nvim's hover, actions and completion.
- `editor.fzf-lua` uses current APIs, live workspace symbols and this
  session's recent files. Pickers report a missing plugin in one line.
- Smaller fixes: `editor.aerial`, `editor.harpoon`, `editor.neotree`,
  `editor.todo-comments`, `ai.claudecode`, `ai.sidekick` (edit suggestions
  load), `ui.base46` (moved repository), `ui.comfy-line-numbers`,
  `ui.animations`, `lang.json` and `git.neogit`.

### Earlier changes in this release

- Fixed extras-menu selection: headings and blank lines no longer toggle an
  unrelated extra. The menu fits small terminals and adjusts when resized.
- Automatic config reload now survives external editors replacing `user.lua`,
  including a syntax error followed by a corrected save. Changes to unrelated
  or unchanged files do not reload Blak, and edits during startup wait until
  setup finishes. Invalid keymap mode names are rejected before
  replacing the accepted configuration.
- One unknown or failing linter no longer prevents the other configured
  linters from running. Blak reports the failing linter separately and honors
  the event's target buffer when linting a background buffer.
- Extras no longer share mutable Snacks option tables between config builds,
  so changes to an active extra cannot alter its defaults on later reloads.
- Clarified the manifesto: supported stable Neovim releases are the baseline;
  nightly is a compatibility target. CI now has a required stable smoke job
  and an advisory nightly smoke job.
- Updated deprecated Neovim highlighting and diagnostic navigation APIs while
  preserving the existing keys. `:BlakKeys` now includes described global
  mappings, including native defaults, and shows the effective mapping when a
  buffer-local mapping overrides a global one.
- `<leader>cf` now works without an attached LSP. `:BlakFormat` accepts line
  ranges, including `:'<,'>BlakFormat` after a visual selection. Disable the
  shortcut with `{ key = "<leader>cf", disable = true }` in `keymaps`.
- Reopening an exited native terminal starts a fresh shell and retains the old
  output buffer. Running terminal jobs are still reused.
- Per-filetype Conform options now override Blak's global formatting defaults
  on save and through `:BlakFormat`. Use `{ lsp_format = "never" }` as a
  filetype's formatter entry to disable formatting for that filetype; an empty
  list alone still allows LSP fallback.
- `lang.typescript` now uses TypeScript 7's native `tsc` language server.
  This is a deliberate distribution upgrade: review this change before
  updating the Blak checkout, then run `:BlakUpgrade`, `:BlakToolsInstall`,
  wait for installation, and restart. To retain `ts_ls`, select the new
  `lang.typescript-legacy` extra when upgrading. Explicit `lsp.servers.ts_ls`
  entries remain configured; remove them to use only the native server.
  `lang.typescript-tsgo` is a compatibility alias for the standard stack and
  carries `tsgo` overrides into `tsc`, with explicit `tsc` settings winning.
  Installed tools remain. Plugin-only `:BlakUpdate` does not fetch this change,
  and rollback snapshots do not restore the Blak checkout revision.
- Overlapping Python or TypeScript language extras now behave consistently
  regardless of activation order. Python Pro supersedes basic Python, and
  native TypeScript supersedes legacy TypeScript. They replace only unchanged
  extra-contributed defaults, preserving explicit user settings. Changes in
  one configuration no longer leak through shared extra server tables.
  Basic Python no longer starts a second Ruff process through nvim-lint; Ruff
  LSP supplies diagnostics. Opt back in with `lint.linters_by_ft.python = { "ruff" }`.

- Fixed TypeScript initialization when a project-local language server cannot
  find TypeScript: `lang.typescript-legacy` resolves a compatible workspace SDK first,
  then Mason's copy, while preserving explicit SDK paths and user hooks.
  Tool installation repairs Mason packages missing `tsserver.js`, including
  incompatible TypeScript 7 installations. Run `:BlakToolsInstall`, wait for
  completion, and restart to recover an existing broken installation.
  `:BlakDoctor` now checks this dependency. Automatic repair follows
  `mason.automatic_install`; see the typescript-runtime migration.
- Configuration functions can remove default LSP servers and formatters without
  the defaults being silently restored. Table-based overrides and explicit
  `setup()` overrides retain their existing precedence.
- Unknown linter names and failing linter factories now produce health warnings
  instead of aborting `:BlakDoctor` before later checks run.

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
- Docs development now requires Node.js 22.12+ (CI uses Node.js 24). Updated
  the GitHub Actions checkout, language setup, and Pages actions.
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
