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

If `picker.provider == "fff"`, confirms `fff.nvim` is `require`-able. If you swapped to telescope or fzf-lua via an extra, those checks live in their respective extras.

### Enabled extras

Lists every extra ID currently in your enabled set, drawn from `extras.enabled` plus the state file. Useful for confirming a `:BlakExtras enable …` actually persisted.

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
| `fff not loadable` | Run `:Lazy sync`, then check `:Lazy log fff.nvim`. The binary downloads during plugin build. |
| `extras.json has unknown id` | The extra was removed or renamed. Edit `stdpath('state')/blak/extras.json` and remove it, or run `:BlakExtras disable <id>`. |

## Where the file lives

```
$XDG_STATE_HOME/blak/extras.json    -- enabled extras
$XDG_STATE_HOME/blak/lockbacks/     -- lockfile backups for :BlakRollback
$XDG_DATA_HOME/lazy/                -- lazy.nvim plugin install root
$XDG_CONFIG_HOME/lazy-lock.json     -- current lockfile (per-NVIM_APPNAME)
```

If `XDG_*` aren't set, defaults are `~/.local/state`, `~/.local/share`, `~/.config`.
