---
title: Commands
description: Every :Blak command, what it does, and where in the source it lives.
---

Blak's surface area is small. Every command starts with `:Blak`. Every command with a keymap also shows up in `:BlakKeys`.

All commands are defined in [`lua/blak/core/commands.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/commands.lua).

## Core

### `:Blak`

Opens a short overview buffer with the canonical command list. The fastest way to remember what's wired up without leaving the editor.

### `:BlakDoctor`

Shorthand for `:checkhealth blak`. Use this when:

- Something feels off after an update.
- An extra reports missing tools.
- You're about to file an issue — paste the output.

The health checks live in [`lua/blak/core/health.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/health.lua) — see the [Health checks guide](/guide/health/).

### `:BlakKeys`

Opens a scratch buffer listing every keymap registered by Blak core and enabled extras, sorted by left-hand side and annotated with mode + description. The "did I bind this myself or did Blak?" question, answered.

### `:BlakNews`

Opens Blak's release notes (`NEWS.md` from the repo) in a scratch buffer. Use this after `:BlakUpdate` to see what changed.

## Pickers

### `:BlakPick {kind}`

Entry point for every picker action. The `{kind}` is one of:

| Kind | What |
| --- | --- |
| `smart` | Project-aware file finder (default if no arg) |
| `files` | Find files in the workspace |
| `grep` | Live grep |
| `buffers` | Buffer list |
| `recent` | Recently opened files |
| `commands` | Ex commands |
| `keymaps` | All keymaps |
| `help` | Help tags |
| `diagnostics` | Workspace diagnostics |
| `lsp_symbols` | Document symbols |
| `workspace_symbols` | Workspace symbols |

These dispatch through [`lua/blak/providers/picker/`](https://github.com/binbandit/blak.nvim/tree/main/lua/blak/providers/picker), so changing `picker.provider` in your `user.lua` swaps the implementation without changing the keymaps. See the [Pickers guide](/guide/pickers/).

## Extras

### `:BlakExtras [list|enable|disable|sync] [id]`

```vim
:BlakExtras list                  " show available + which are enabled
:BlackExtras list                 " alias for :BlakExtras
:BlakExtras enable lang.rust      " turn on the rust extra
:BlakExtras disable lang.rust     " turn it off
:BlakExtras sync                  " run :Lazy sync to install/uninstall plugins
```

State lives in `stdpath('state')/blak/extras.json`. Enabling applies config to the current session; disabling persists immediately but already-loaded runtime pieces may remain until restart. See the [Extras guide](/guide/extras/) for the full list.

## Update & rollback

### `:BlakUpdate`

1. Backs up the current `lazy-lock.json` to `stdpath('state')/blak/lockbacks/lazy-lock-YYYYMMDD-HHMMSS.json`.
2. Runs `:Lazy update`.

The backup also runs automatically on any `LazyUpdatePre` event, so even a bare `:Lazy update` is safe.

### `:BlakUpgrade`

For intentional bigger moves — channel changes, major-version bumps. Exists separately from `:BlakUpdate` so that stable updates never silently swap a major workflow component.

### `:BlakRollback`

1. Finds the most recent backup in the lockfile backup directory.
2. Restores it as `lazy-lock.json`.
3. Runs `:Lazy restore`.

Result: every plugin returns to the exact commit it was at before the last `:BlakUpdate`. Works offline.

See the [Updates & rollback guide](/guide/updates/) for the full machinery.

## Tools & parsers

### `:BlakToolsInstall`

Force-installs every Mason tool declared in `mason.ensure_installed` plus anything contributed by enabled extras. Useful after enabling a new extra, or on a fresh machine. Implementation: [`lua/blak/core/tools.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/tools.lua).

### `:BlakTreesitterInstall`

Installs every parser in `treesitter.ensure_installed` using the nvim-treesitter `main` branch API. Notifies on completion. Implementation: [`lua/blak/core/treesitter.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/treesitter.lua).

Blak can install `tree-sitter-cli` through Mason on first launch (it's in the default Mason set), then this command compiles parsers.

## Terminal

### `:BlakTerminal [cmd]`

Toggles a bottom split backed by Neovim's native terminal. Without an argument it opens your shell; with an argument it runs that command.

The keymap `<leader>tt` calls the no-argument form.

## Formatting

### `:BlakFormat`

Formats the current buffer via Conform, falling back to the LSP based on `format.lsp_format` (default `"fallback"`).

### `:BlakFormatToggle[!]`

Toggles format-on-save.

- `:BlakFormatToggle` toggles for the current buffer (`vim.b.blak_disable_autoformat`).
- `:BlakFormatToggle!` toggles globally (`vim.g.blak_disable_autoformat`).

The keymap `<leader>uf` calls the buffer version. See the [Formatting guide](/guide/formatting/).

## Splash

### `:BlakSplash`

Plays the black-hole animation in a scratch buffer. Useful for tweaking your terminal's color rendering — and a fun cold open. See the [Splash guide](/guide/splash/).

## Cheat sheet

```text
:Blak                      overview
:BlakDoctor                health checks
:BlakKeys                  registered keymaps
:BlakNews                  release notes
:BlakPick {kind}           picker entrypoint
:BlakExtras list           optional modules
:BlackExtras list          alias for :BlakExtras
:BlakExtras enable {id}    turn on an extra
:BlakExtras disable {id}   turn off an extra
:BlakExtras sync           :Lazy sync after changes
:BlakUpdate                update + lockfile snapshot
:BlakRollback              restore last lockfile snapshot
:BlakUpgrade               explicit bigger moves
:BlakToolsInstall          install Mason tools
:BlakTreesitterInstall     install parsers
:BlakTerminal [cmd]        native terminal split
:BlakFormat                format current buffer
:BlakFormatToggle[!]       toggle format-on-save
:BlakSplash                preview splash animation
```
