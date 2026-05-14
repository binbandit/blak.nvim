# blak.nvim

**Blak** is a native-first Neovim distribution built around a black-hole aesthetic and a strict product contract:

> Everything useful. Nothing escapes.

It is designed to be installable in one command, useful out of the box, easy to understand, and safe to extend through reversible extras.

## Status

Blak is launching as a **v0.1 public preview**: complete enough to install, use, and share, while still young enough that issues and contributor feedback are expected.

## Requirements

- Neovim 0.12+
- Git
- `rg` for search
- `fd` for faster file discovery
- `tree-sitter` CLI for nvim-treesitter parser installation; Blak can install `tree-sitter-cli` through Mason on first launch, then `:BlakTreesitterInstall` can install parsers.
- A Nerd Font is recommended, not required

## Install

After the repository is pushed to `binbandit/blak.nvim`:

```sh
curl -fsSL https://raw.githubusercontent.com/binbandit/blak.nvim/main/install.sh | sh
blak
```

The installer clones Blak to `~/.config/blak`, creates a small `~/.local/bin/blak` launcher, and uses `NVIM_APPNAME=blak`, so it does not overwrite an existing Neovim config.

For development from this checkout:

```sh
git clone https://github.com/binbandit/blak.nvim ~/.config/blak
NVIM_APPNAME=blak nvim
```

## What ships by default

- `lazy.nvim` backend with a lockfile and rollback support
- `fff.nvim` as the primary file picker, using the canonical `dmtrKovalenko/fff` repository
- Snacks dashboard/input/notifier/picker/quickfile/bigfile modules
- Animated black-hole splash extracted from the milli.nvim blackhole GIF preview
- `blink.cmp` completion
- Native Neovim LSP setup using `vim.lsp.config()` and `vim.lsp.enable()` via `mason-lspconfig`
- Mason for external tools
- Conform for formatting
- nvim-lint for standalone linters
- nvim-treesitter
- Oil as the default file explorer
- Gitsigns
- Which-key for discoverability
- A small monochrome `blak` colorscheme

## Core commands

```vim
:Blak              overview
:BlakDoctor        health checks
:BlakKeys          keymaps registered by Blak
:BlakPick files    picker entrypoint
:BlakExtras        list optional extras
:BlakUpdate        update plugins with lockfile backup
:BlakRollback      restore last lockfile backup and run Lazy restore
:BlakToolsInstall  install Mason tools required by enabled extras
:BlakTreesitterInstall install configured Treesitter parsers
:BlakSplash        preview the black-hole animation
```

## Extras

Extras are opt-in and reversible:

```vim
:BlakExtras list
:BlakExtras enable lang.typescript
:BlakExtras enable lang.python
:BlakExtras enable git.lazygit
:BlakExtras disable lang.python
```

State is stored in `stdpath('state')/blak/extras.json`, not in the repo. Restart Blak after changing extras, then run `:Lazy sync` if the enabled set added or removed plugins.

## Customization

Copy the example:

```sh
cp ~/.config/blak/lua/blak/user.example.lua ~/.config/blak/lua/blak/user.lua
```

Then edit `lua/blak/user.lua`:

```lua
return {
  picker = { provider = "fff" },
  extras = {
    enabled = { "lang.typescript", "git.lazygit" },
  },
}
```

## Philosophy

Blak should feel like a polished editor immediately, but never like a mystery box. Defaults live in `lua/blak/config/defaults.lua`, plugin specs live in `lua/blak/plugins/`, provider adapters live in `lua/blak/providers/`, and extras live in `lua/blak/extras/`.

Stable updates must not silently swap major workflow components. `:BlakUpdate` creates rollback points; `:BlakUpgrade` exists for intentional bigger moves.

## Before posting

```sh
make validate
make smoke
```

`make validate` is static and works without Neovim. `make smoke` runs Neovim headless and should be run locally on a machine with Neovim 0.12+. GitHub Actions runs static validation and a Neovim smoke test on every push and pull request.
