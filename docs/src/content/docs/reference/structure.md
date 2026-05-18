---
title: Directory layout
description: Where every Blak module lives, so you can read the source without grepping.
---

Blak's design is "if you can find a directory in this list, you can find the thing inside it." The layout is intentionally flat and physical — files match concepts.

## Repository root

```text
blak.nvim/
├── init.lua                Entry point — calls require("blak").setup(...)
├── install.sh              One-command public installer
├── dev-install.sh          Local-symlink installer for hacking on Blak
├── Makefile                validate, smoke, docs-*, zip targets
├── README.md               High-level intro
├── NEWS.md                 Per-release changelog (also shown by :BlakNews)
├── CONTRIBUTING.md         Design rules + dev loop
├── NOTICE                  Third-party attribution
├── LICENSE                 MIT
├── VALIDATION.md           CI validation notes
├── lazy-lock.json          Committed lockfile (what the world gets on first run)
├── .stylua.toml            Lua formatter config
├── .editorconfig
├── doc/                    Vim helpfiles (:help blak)
├── assets/                 GIF + braille source for the splash
├── lua/blak/               The runtime — everything else
├── scripts/                Python validator + Lua smoke tests
├── docs/                   This documentation site (Astro Starlight)
└── .github/workflows/      CI: validate, smoke, docs deploy
```

## `lua/blak/`

```text
lua/blak/
├── init.lua                M.setup() — the top-level orchestrator
├── lazy.lua                Bootstrap lazy.nvim, register plugin specs
├── util.lua                Helpers: notify, try_require, file I/O, git_root, …
├── health.lua              Bridge: makes :checkhealth blak find core.health
├── user.example.lua        The starter user.lua, copied during install
│
├── config/
│   ├── init.lua            Merge: defaults + vim.g.blak_config + user.lua + setup opts
│   ├── defaults.lua        Canonical default config
│   └── schema.lua          Validation rules + error reporting
│
├── core/
│   ├── options.lua         vim.opt.* applied at startup
│   ├── autocmds.lua        Yank highlight, cursor restore, FT close-on-q, …
│   ├── commands.lua        Every :Blak* user command
│   ├── explorer.lua        Configured explorer dispatcher
│   ├── keymaps.lua         All keymaps + :BlakKeys
│   ├── terminal.lua        Configured terminal provider used by :BlakTerminal
│   ├── treesitter.lua      Parser install, FileType activation
│   ├── tools.lua           Mason install orchestration
│   ├── update.lua          :BlakUpdate / :BlakRollback / :BlakNews
│   └── health.lua          :checkhealth blak
│
├── plugins/
│   ├── init.lua            Plugin spec collector
│   ├── ui.lua              Snacks, which-key
│   ├── editor.lua          mini.icons, nvim-treesitter, oil.nvim
│   ├── picker.lua          fff.nvim (when picker.provider == "fff")
│   ├── completion.lua      blink.cmp
│   ├── lsp.lua             nvim-lspconfig, mason, mason-lspconfig
│   ├── formatting.lua      conform.nvim, nvim-lint
│   └── git.lua             gitsigns.nvim
│
├── providers/
│   └── picker/
│       ├── init.lua        Dispatcher with fallback chain
│       ├── fff.lua         fff.nvim adapter
│       ├── snacks.lua      Snacks picker adapter
│       ├── telescope.lua   Telescope adapter
│       └── fzf_lua.lua     fzf-lua adapter
│
├── extras/
│   ├── init.lua            Extra registry, :BlakExtras command
│   ├── state.lua           Persisted enabled-set (state file)
│   ├── lang/
│   │   ├── lua.lua
│   │   ├── typescript.lua
│   │   ├── typescript_tsgo.lua
│   │   ├── python.lua
│   │   ├── rust.lua
│   │   ├── go.lua
│   │   └── markdown.lua
│   ├── ui/
│   │   ├── animations.lua
│   │   ├── base46.lua
│   │   ├── image_preview.lua
│   │   ├── lualine.lua
│   │   └── zen.lua
│   ├── git/
│   │   ├── lazygit.lua
│   │   └── diffview.lua
│   ├── ai/
│   │   ├── copilot.lua
│   │   └── sidekick.lua
│   └── editor/
│       ├── neotree.lua
│       ├── snacks_explorer.lua
│       ├── snacks_terminal.lua
│       ├── telescope.lua
│       └── fzf_lua.lua
│
└── splash/
    ├── init.lua            Renderer + Snacks integration
    └── frames/
        └── blackhole.lua   Braille frame data (auto-generated)
```

## `scripts/`

```text
scripts/
├── validate.py             Static checks: Lua syntax, require paths,
│                           extra ids, splash frame structure,
│                           required docs, legacy-identifier cleanup
├── smoke.lua               Runtime smoke test: setup + checkhealth
├── commands.lua            Command-contract smoke test for every :Blak command
└── smoke-directory.lua     Directory argument smoke test for `blak .`
```

## `docs/`

```text
docs/
├── package.json
├── astro.config.mjs
├── tsconfig.json
├── public/                 Static assets (favicon)
├── scripts/
│   └── extract-splash.py   Lua frames → JSON for the website hero
└── src/
    ├── content.config.ts
    ├── assets/             Logo SVG
    ├── data/splash.json    Generated splash frame data
    ├── components/         Hero, Splash, SiteTitle, …
    ├── styles/custom.css   Site theme
    └── content/docs/       The pages you're reading
```

## State, data, cache (created at runtime)

```text
$XDG_CONFIG_HOME/blak/                          The clone (NVIM_APPNAME=blak)
$XDG_CONFIG_HOME/blak/lua/blak/user.lua         Your overrides (gitignored)
$XDG_CONFIG_HOME/lazy-lock.json                 Current lockfile

$XDG_DATA_HOME/blak/                            Plugin install root (lazy.nvim)
$XDG_DATA_HOME/blak/lazy/                       Cloned plugins
$XDG_DATA_HOME/blak/mason/                      Mason packages (binaries + shims)

$XDG_STATE_HOME/blak/extras.json                Enabled extras
$XDG_STATE_HOME/blak/lockbacks/                 Lockfile snapshots (rollback)
```

Defaults if `XDG_*` aren't set: `~/.config`, `~/.local/share`, `~/.local/state`.

## Rules of thumb

- **Configuration vs. plugin specs** — config lives in `lua/blak/config/`; plugin specs live in `lua/blak/plugins/`. They're not mixed.
- **Core vs. extras** — if it's always loaded, it's `lua/blak/core/` or `lua/blak/plugins/`. If it's optional, it's `lua/blak/extras/`.
- **Providers** — anywhere Blak has a "swap the backend without changing keymaps" story, the adapters live in `lua/blak/providers/`.
- **Splash** — the splash gets its own top-level dir because the frame data file is large and the renderer is non-trivial.
