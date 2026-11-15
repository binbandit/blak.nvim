---
title: Health checks
description: What :BlakDoctor checks, what each result means, and what to do when something fails.
---

`:BlakDoctor` runs `:checkhealth blak`, which executes the health check module at [`lua/blak/core/health.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/health.lua).

Run it after:

- A fresh install.
- Enabling or disabling an extra.
- A `:BlakUpdate` if anything feels off.
- Before filing an issue — paste the output.

## What it checks

### Blak environment

- **Neovim version** — must be 0.12 or newer. Native LSP wiring requires it.
- **`termguicolors`** — must be on. Without it the splash and colorscheme look wrong.

### Binaries on `$PATH`

The checker probes for each tool with `vim.fn.executable`. Missing tools warn but don't fail.

| Binary | Used for |
| --- | --- |
| `git` | Plugin install via lazy.nvim |
| `rg` (ripgrep) | Backing grep for pickers, `:grep` |
| `fd` | Faster file enumeration than the built-in walk |
| `tree-sitter` | Compiling parsers (`:BlakTreesitterInstall`) |

### Picker

If `picker.provider == "fff"`, confirms fff.nvim can actually run. `require("fff")` isn't enough: it resolves to `fff.main`, which defers the Rust backend into function bodies and so succeeds even with no native library on disk. The check probes the backend directly, and distinguishes three failures:

- **Plugin not loadable**: fff.nvim isn't installed yet. Run `:BlakExtras sync` and restart.
- **Native library missing** — the plugin is there but the Rust library was never built or downloaded.
- **Stranded download** — the library was downloaded and verified, but fff couldn't install it because the old one was still loaded, so it sits at `<binary>.tmp`. Nothing on fff's require path promotes it, so this survives restarts until you re-run the download.

If you swapped to telescope or fzf-lua via an extra, the Enabled extras check below reports whether that picker's plugin is installed.

### Enabled extras

Lists every extra ID currently in your enabled set, drawn from `extras.enabled` plus the state file. Useful for confirming a `:BlakExtras enable …` actually persisted.

Each known extra is OK when lazy.nvim has installed every plugin it declares. Otherwise it warns with the missing plugin names; run `:BlakExtras sync`, then `:restart`.

### Linters

Lists every linter configured in `lint.linters_by_ft` (yours plus contributions
from enabled extras) and resolves each one's command the same way the lint
runner does. A linter whose binary isn't on `$PATH` warns here — Blak skips it
at lint time rather than raising an error on every save, so this section is how
you find out it never ran. See [Linting](/guide/linting/) for the details.

### Mason tools

Checks every tool the merged config wants installed (`mason.ensure_installed` + contributions from enabled extras), plus `typescript-language-server` when `ts_ls` is configured. Each tool is OK when Mason has it installed and warns when it is missing. Run `:BlakToolsInstall` to install the configured tool set, and check `:MasonLog` when an install keeps failing. Language servers that mason-lspconfig installs for `lsp.servers` are not listed here; `:checkhealth vim.lsp` shows which ones are running.

### TypeScript

When `ts_ls` is configured, checks that Mason's fallback TypeScript SDK contains
`tsserver.js` and package metadata. A missing fallback warns with repair
instructions: run `:BlakToolsInstall`, wait for completion, and restart. A
compatible workspace SDK or explicit `init_options.tsserver.path` can supply
TypeScript independently of Mason. See [TypeScript SDK and initialization
errors](/extras/lang/typescript-legacy/#typescript-sdk-and-initialization-errors).

## Sample output

With `lang.markdown` and `git.diffview` enabled in `user.lua`, and
`editor.trouble` enabled in-session without running `:BlakExtras sync` yet:

```text
blak:                                                                     4 ⚠️

Blak ~
- ✅ OK Neovim >= 0.12
- ✅ OK termguicolors is enabled
- ✅ OK git found
- ✅ OK rg found
- ✅ OK fd found
- ✅ OK tree-sitter found
- ✅ OK fff.nvim is loadable

Enabled extras ~
- ⚠️ WARNING editor.trouble needs plugins that are not installed: trouble.nvim. Run :BlakExtras sync, then :restart.
- ✅ OK git.diffview
- ✅ OK lang.markdown

Linters ~
- ✅ OK markdownlint found

Mason tools ~
- ⚠️ WARNING markdownlint is not installed. Run :BlakToolsInstall; see :MasonLog if it keeps failing.
- ⚠️ WARNING prettier is not installed. Run :BlakToolsInstall; see :MasonLog if it keeps failing.
- ⚠️ WARNING prettierd is not installed. Run :BlakToolsInstall; see :MasonLog if it keeps failing.
- ✅ OK shfmt
- ✅ OK stylua
- ✅ OK tree-sitter-cli
```

## When something fails

| Symptom | Fix |
| --- | --- |
| `Blak targets Neovim 0.12+` | Upgrade to 0.12+. Blak and its current plugins target that version. |
| `termguicolors is required` | Set `vim.opt.termguicolors = true` in your terminal config, or check your `$TERM` value. |
| `git not found` | Install git. Lazy.nvim needs it to clone plugins. |
| `tree-sitter not found` | Run `:BlakToolsInstall` to get `tree-sitter-cli` from Mason, then `:BlakTreesitterInstall`. |
| `rg not found` | Install ripgrep. Without it pickers fall back to slow built-in walks. |
| `fff.nvim is not loadable yet` | Run `:BlakExtras sync`, then check `:Lazy log fff.nvim`. The binary downloads during plugin build. |
| `fff.nvim ... native library is missing` | Run `:lua require("fff.download").download_or_build_binary()`, then restart. Without it the picker throws a Rust backend error on startup. |
| `fff.nvim downloaded its native library but could not install it` | Same command, then restart. The download is complete and sitting at `<binary>.tmp`; running it again promotes the file. |
| `<linter> not found` | The linter isn't on `$PATH`, so it is skipped silently at lint time. Run `:BlakToolsInstall` if Mason ships it, or install it yourself. |
| `<extra> needs plugins that are not installed` | Run `:BlakExtras sync` to install them at their pinned commits, then `:restart`. |
| `<tool> is not installed` | Run `:BlakToolsInstall`. If it keeps failing, `:MasonLog` has the installer output; some packages need a runtime such as Python, Node.js, or Go on `$PATH`. |
| `<linter> is configured but nvim-lint has no such linter` | The name in `lint.linters_by_ft` doesn't match any nvim-lint linter. Check the spelling against [nvim-lint's linter list](https://github.com/mfussenegger/nvim-lint#available-linters). |
| `Unknown extra: <id>` | The extra was removed or renamed. Run `:BlakExtras disable <id>` to remove the stale state entry. If it is still listed in `lua/blak/user.lua`, remove it there too. |

## Where the file lives

```
$XDG_STATE_HOME/blak/extras.json    -- enabled extras
$XDG_STATE_HOME/blak/update.json    -- accepted update channel
$XDG_STATE_HOME/blak/rollbacks/     -- config-aware rollback snapshots
$XDG_STATE_HOME/blak/lockbacks/     -- legacy lockfile-only backups
$XDG_DATA_HOME/lazy/                -- lazy.nvim plugin install root
$XDG_STATE_HOME/blak/lazy-lock.json -- your lockfile, seeded from the shipped pins
```

If `XDG_*` aren't set, defaults are `~/.local/state`, `~/.local/share`, `~/.config`.
