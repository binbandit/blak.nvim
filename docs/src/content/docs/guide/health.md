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

- **Plugin not loadable** — fff.nvim isn't installed yet. Run `:Lazy sync` and restart.
- **Native library missing** — the plugin is there but the Rust library was never built or downloaded.
- **Stranded download** — the library was downloaded and verified, but fff couldn't install it because the old one was still loaded, so it sits at `<binary>.tmp`. Nothing on fff's require path promotes it, so this survives restarts until you re-run the download.

If you swapped to telescope or fzf-lua via an extra, those checks live in their respective extras.

### Enabled extras

Lists every extra ID currently in your enabled set, drawn from `extras.enabled` plus the state file. Useful for confirming a `:BlakExtras enable …` actually persisted.

### Linters

Lists every linter configured in `lint.linters_by_ft` (yours plus contributions
from enabled extras) and resolves each one's command the same way the lint
runner does. A linter whose binary isn't on `$PATH` warns here — Blak skips it
at lint time rather than raising an error on every save, so this section is how
you find out it never ran. See [Linting](/guide/linting/) for the details.

### Mason tools

Lists every tool the merged config wants installed (`mason.ensure_installed` + contributions from enabled extras). Doesn't actually probe Mason — just shows the set. Run `:Mason` to see install status, or `:BlakToolsInstall` to install Blak's configured tool set.

## Sample output

```text
Blak
- ok: Neovim 0.12 detected
- ok: termguicolors enabled

Binaries
- ok: git
- ok: rg
- ok: fd
- warning: tree-sitter missing — install via Mason (:Mason)

Picker
- ok: fff loadable

Enabled extras
- lang.lua
- git.lazygit

Linters
- warning: markdownlint not found; it is skipped until installed. Run :BlakToolsInstall.
- ok: shellcheck found

Mason tools
- stylua
- shfmt
- tree-sitter-cli
- lazygit
```

## When something fails

| Symptom | Fix |
| --- | --- |
| `Neovim X.Y is too old` | Upgrade to 0.12+. The native LSP API doesn't exist before. |
| `termguicolors disabled` | Set `vim.opt.termguicolors = true` in your terminal config, or check your `$TERM` value. |
| `git not found` | Install git. Lazy.nvim needs it to clone plugins. |
| `rg not found` | Install ripgrep. Without it pickers fall back to slow built-in walks. |
| `fff.nvim is not loadable yet` | Run `:Lazy sync`, then check `:Lazy log fff.nvim`. The binary downloads during plugin build. |
| `fff.nvim ... native library is missing` | Run `:lua require("fff.download").download_or_build_binary()`, then restart. Without it the picker throws a Rust backend error on startup. |
| `fff.nvim downloaded its native library but could not install it` | Same command, then restart. The download is complete and sitting at `<binary>.tmp`; running it again promotes the file. |
| `<linter> not found` | The linter isn't on `$PATH`, so it is skipped silently at lint time. Run `:BlakToolsInstall` if Mason ships it, or install it yourself. |
| `<linter> is configured but nvim-lint has no such linter` | The name in `lint.linters_by_ft` doesn't match any nvim-lint linter. Check the spelling against [nvim-lint's linter list](https://github.com/mfussenegger/nvim-lint#available-linters). |
| `Unknown extra: <id>` | The extra was removed or renamed. Run `:BlakExtras disable <id>` to remove the stale state entry. If it is still listed in `lua/blak/user.lua`, remove it there too. |

## Where the file lives

```
$XDG_STATE_HOME/blak/extras.json    -- enabled extras
$XDG_STATE_HOME/blak/update.json    -- accepted update channel
$XDG_STATE_HOME/blak/rollbacks/     -- config-aware rollback snapshots
$XDG_STATE_HOME/blak/lockbacks/     -- legacy lockfile-only backups
$XDG_DATA_HOME/lazy/                -- lazy.nvim plugin install root
$XDG_CONFIG_HOME/lazy-lock.json     -- current lockfile (per-NVIM_APPNAME)
```

If `XDG_*` aren't set, defaults are `~/.local/state`, `~/.local/share`, `~/.config`.
