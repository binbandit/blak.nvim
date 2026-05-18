---
title: Writing an extra
description: A step-by-step recipe for adding a new opt-in module.
---

Extras are the right place for any capability that doesn't belong in core — language support, optional plugins, alternative providers, opinionated tweaks. The contract is small and the reward is automatic: enable / disable from `:BlakExtras` works for free.

## When something should be an extra

Use the [philosophy](/guide/philosophy/) rules:

- **Most users benefit?** → core (`lua/blak/plugins/` or `lua/blak/core/`).
- **Some users benefit, and the cost of carrying it is non-zero?** → extra.
- **Just personal taste?** → your own `user.lua`.

## Anatomy

Create a file at `lua/blak/extras/<group>/<name>.lua`. Groups today: `lang`, `ui`, `git`, `ai`, `editor`. Add a new group folder if your extra doesn't fit.

The file returns a single table:

```lua
return {
  id = "lang.zig",                          -- unique, dotted, matches path
  label = "Zig",                            -- short human label
  description = "zls + treesitter",         -- one line shown by :BlakExtras list

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
:BlakExtras list
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
- The file's Lua syntax balances delimiters and keywords.

Then a smoke run:

```sh
make smoke
```

Boots Neovim headless, calls `require("blak").setup()`, and runs `:checkhealth blak`.

## Document it

Two places, both in this repo:

1. Add a row to the [Extras guide](/guide/extras/) (`docs/src/content/docs/guide/extras.md`).
2. If the extra adds a keymap, mention it in the [Keymaps page](/guide/keymaps/) under "Keymaps added by extras."

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
