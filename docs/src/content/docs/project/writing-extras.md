---
title: Writing an extra
description: A step-by-step recipe for adding a new opt-in module.
---

Extras are the right place for any capability that doesn't belong in core — language support, optional plugins, alternative providers, opinionated tweaks. The contract is small and the reward is automatic: enable / disable from `:BlakExtras` works for free.

## When something should be an extra

Use the [philosophy](/guide/philosophy/) rules:

- **Most users benefit?** → core (`lua/blak/plugins/` or `lua/blak/core/`).
- **Some users benefit, and the cost of carrying it is non-zero?** → extra.
- **Just personal taste?** → your own `user.lua` or `plugins.specs`.

## Anatomy

Create a file at `lua/blak/extras/<group>/<name>.lua`. Groups today: `lang`, `ui`, `git`, `ai`, `editor`. Add a new group folder if your extra doesn't fit.

The file returns a single table:

```lua
return {
  id = "lang.zig",                          -- unique, dotted, matches path
  label = "Zig",                            -- short human label
  description = "zls + treesitter",         -- one line shown in :BlakExtras

  -- Any of these are optional; include only the ones your extra needs.
  treesitter = { "zig" },                   -- merged into ensure_installed
  mason = { "zls" },                        -- merged into mason.ensure_installed
  lsp = {
    servers = {
      zls = {
        settings = { zls = { enable_inlay_hints = true } },
      },
    },
  },
  format = {
    formatters_by_ft = { zig = { "zigfmt" } },
  },
  lint = {
    linters_by_ft = { zig = { "ziggrep" } },
  },
  snacks = {
    dim = { enabled = true },               -- deep-merged into snacks opts
  },
  keys = {                                  -- show up in :BlakKeys
    { lhs = "<leader>cc", rhs = ":!zig build<CR>", desc = "zig build" },
  },
  plugins = {                               -- lazy.nvim specs added to the set
    { "ziglang/zig.vim", ft = "zig" },
  },
  apply = function(config)                  -- runs after merge, before plugin load
    -- escape hatch for anything the declarative fields don't cover
    config.snacks.scroll = { enabled = false }
  end,
}
```

## Performance contract

Extras are opt-in, but they still must not become surprise startup cost. Every plugin spec in an extra must lazy-load with one of these:

- `cmd` for command-driven tools.
- `ft` for language or filetype-specific behavior.
- `event` for UI that can appear after startup, such as `VeryLazy`.
- `keys` when lazy.nvim owns the mapping.
- `lazy = true` only when Blak keymaps or provider code explicitly load the plugin on demand.

Avoid `lazy = false` in extras. If a feature truly has to load at startup, it probably belongs in core or needs a design discussion first.

## Register it

Add the require path to the module list in [`lua/blak/extras/init.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/extras/init.lua):

```lua
local modules = {
  -- ...
  "blak.extras.lang.zig",
}
```

That's the entire registration. The registry caches results and looks up extras by their `id` field, so the order of `modules` doesn't matter.

## Test it locally

```sh
./dev-install.sh
blak-dev
:BlakExtras
:BlakExtras enable lang.zig
:Lazy sync                           " if plugins changed
:BlakToolsInstall                    " if mason changed
:BlakTreesitterInstall               " if parsers changed
:BlakDoctor                          " confirm everything resolved
```

Then exercise the actual behavior — open a `.zig` file, check LSP attaches (`:lua = vim.lsp.get_clients()`), confirm formatting works.

## Validate

```sh
make validate
```

The static checker enforces:

- The require path in `modules` matches an actual file.
- The file's `id` field is unique across all extras.
- Plugin specs lazy-load with `cmd`, `event`, `ft`, `keys`, or explicit `lazy = true`.
- The file's Lua syntax balances delimiters and keywords.

Then a smoke run:

```sh
make smoke
```

Boots Neovim headless, calls `require("blak").setup()`, and runs `:checkhealth blak`.

## Document it

A few places, all in this repo:

1. Add a dedicated page under `docs/src/content/docs/extras/<group>/<name>.md`.
2. Link that page from the [Extras guide](/guide/extras/) and the docs sidebar in `docs/astro.config.mjs`.
3. If the extra adds a keymap, mention it in the [Keymaps page](/guide/keymaps/) under "Keymaps added by extras."

## Open a PR

Describe what the extra adds and why it isn't a core feature. The bar for core is high — extras are the path of least resistance.

## Reversibility checklist

When the extra is disabled, every one of these should be undone automatically because the runtime composes contributions from `enabled()` on each setup:

- ✅ Treesitter parsers — removed from the install list (already-installed parsers stay until you uninstall manually; that's fine).
- ✅ Mason tools — removed from the install list.
- ✅ LSP servers — the `vim.lsp.config()` entry isn't registered.
- ✅ Formatters / linters — not added to the by-filetype maps.
- ✅ Keymaps — not registered.
- ✅ Plugin specs — lazy.nvim removes them on the next `:Lazy sync`.

If your extra has side effects beyond these (writes a file, mutates a global), undo them in a second function or document them in the extras guide so users know.
