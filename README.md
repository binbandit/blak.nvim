# blak.nvim

<p align="center">
  <img src="./assets/blak-ascii.svg" alt="blak.nvim ASCII black-hole logo" width="720">
</p>

**Blak** is a native-first Neovim distribution built around a black-hole aesthetic and a strict product contract:

> Everything useful. Nothing escapes.

It is designed to be installable in one command, useful out of the box, easy to understand, and safe to extend through reversible extras.

The longer promise lives in [MANIFESTO.md](MANIFESTO.md):

> We use native Neovim first.
> We ship only what earns its gravity.
> We do not hide configuration behind magic.
> We do not break your muscle memory on update.
> We make extras easy, reversible, and documented.

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

```sh
curl -fsSL https://getblak.dev/install.sh | sh
blak
```

The installer creates a sparse runtime checkout at `~/.config/blak`, creates a small `~/.local/bin/blak` launcher, and uses `NVIM_APPNAME=blak`, so it does not overwrite an existing Neovim config. The checkout keeps the editor runtime, help files, picker ignore metadata, lockfile, changelog, license, notice, README, and logo; development files such as `docs/`, `scripts/`, `.github/`, and generated splash assets are left out.

For development from this checkout:

```sh
git clone https://github.com/binbandit/blak.nvim ~/.config/blak
NVIM_APPNAME=blak nvim
```

## Default Kit

Blak's defaults are intentionally small. They cover the editing floor and leave preference-heavy features as extras.

- Package backend: `lazy.nvim`, committed lockfile, rollback snapshots
- Picker: `fff.nvim` for files and grep, with Snacks fallback for broader picker actions
- UI: Snacks dashboard/input/notifier/picker/quickfile/bigfile/words, plus the animated black-hole splash
- Completion: `blink.cmp` on the stable `1.*` line
- LSP: native `vim.lsp.config()` with `mason-lspconfig` handling Mason-backed `vim.lsp.enable()`
- Tools: Mason, Conform, nvim-lint, nvim-treesitter
- Editing: Oil file explorer, native terminal split, Gitsigns, which-key, `mini.icons`
- Theme: TokyoNight Night (`tokyonight-night`)

## Core commands

```vim
:Blak              overview
:BlakDoctor        health checks
:BlakKeys          keymaps registered by Blak
:BlakNews          release notes
:BlakConfig        open or create lua/blak/user.lua
:BlakPick files    picker entrypoint
:BlakExtras        extras UI
:BlackExtras       alias for :BlakExtras
:BlakUpdate        update plugins with lockfile backup
:BlakUpgrade       intentional bigger moves
:BlakRollback      restore last lockfile backup and run Lazy restore
:BlakToolsInstall  install Mason tools required by enabled extras
:BlakTreesitterInstall install configured Treesitter parsers
:BlakTerminal [cmd] toggle a native terminal split
:BlakFormat        format current buffer
:BlakFormatToggle  toggle format-on-save
:BlakSplash        preview the black-hole animation
```

Most Blak management shortcuts live under `<Space>l`: `<Space>le` opens extras,
`<Space>lc` opens config, and `<Space>lk` shows registered keymaps. Run
`:BlakKeys` for the full list.

## Extras

Extras are opt-in and reversible:

```vim
:BlakExtras
:BlakExtras list
:BlakExtras enable lang.typescript
:BlakExtras enable lang.python
:BlakExtras enable git.lazygit
:BlakExtras enable ui.base46
:BlakExtras enable ui.lualine
:BlakExtras enable editor.snacks-explorer
:BlakExtras disable lang.python
```

The `:BlakExtras` UI shows enabled and available extras in sections. Press `x`
or `<CR>` on an extra to toggle it, `s` to run `:Lazy sync`, and `q` to close.
Extras listed in `lua/blak/user.lua` are shown as config-managed and should be
removed there when you want them disabled.

Use `lang.typescript-tsgo` instead of `lang.typescript` to try the experimental native TypeScript LSP.

State is stored in `stdpath('state')/blak/extras.json`, not in the repo. Enabling an extra applies its config to the current session; run `:BlakExtras sync` if the extra added plugin specs. Disabling persists immediately, but a restart is still the clean way to unload plugins, keymaps, and runtime hooks that already ran.

Default vs. optional is deliberate:

- Language stacks are extras because most users do not need every server, formatter, linter, and parser.
- Alternative pickers and explorers are extras because they replace muscle-memory surfaces.
- LazyGit, Diffview, Copilot, image preview, theme collections, statuslines, zen mode, and animations are extras because they are valuable but preference-heavy.

## Customization

Open your config from inside Blak:

```vim
:BlakConfig
```

That creates `lua/blak/user.lua` from the example when it does not exist yet.
From a shell, the same setup is:

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

When Blak is already running, saving `lua/blak/user.lua` reloads the merged
config and refreshes the current session. Plugin installs/removals still go
through `:BlakExtras sync` or `:Lazy sync`; restarting remains the clean way to
unload plugins, keymaps, or runtime hooks that already ran.

## Philosophy

Blak should feel like a polished editor immediately, but never like a mystery box. Defaults live in `lua/blak/config/defaults.lua`, plugin specs live in `lua/blak/plugins/`, provider adapters live in `lua/blak/providers/`, and extras live in `lua/blak/extras/`.

Stable updates must not silently swap major workflow components. `:BlakUpdate` creates rollback points; `:BlakUpgrade` exists for intentional bigger moves.

## Before posting

```sh
make validate
make smoke
make smoke-install
```

`make validate` is static and works without Neovim. `make smoke` runs Neovim headless against the checkout, and `make smoke-install` runs the public installer into temporary XDG directories and boots that sparse install. GitHub Actions runs all three on every push and pull request.

## Documentation

The full documentation site lives at [getblak.dev](https://getblak.dev/) and is built from `docs/` with [Astro Starlight](https://starlight.astro.build/).

To run it locally:

```sh
cd docs
npm install
npm run dev      # http://localhost:4321/
```

Or via the Makefile from the repo root:

```sh
make docs-install
make docs-dev
make docs-build
```

The site auto-deploys to [getblak.dev](https://getblak.dev/) via GitHub Pages on every push to `main` via `.github/workflows/docs.yml`.
