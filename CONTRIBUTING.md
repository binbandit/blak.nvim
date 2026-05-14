# Contributing to Blak

Blak is optimized for maintainability first. A feature belongs in core only if most users benefit from it. Everything else should be an extra.

## Design rules

1. Prefer native Neovim APIs before adding plugins.
2. Keep defaults boring, memorable, and documented.
3. Do not add hidden keymaps. Every keymap needs a description and should appear in `:BlakKeys`.
4. Stable updates must not silently change a user's picker, completion engine, explorer, or LSP strategy.
5. Extras must be reversible.
6. If a smart simple solution solves the problem without compromise, use it.

## Layout

```text
lua/blak/config/     defaults and validation
lua/blak/core/       options, commands, keymaps, health, update, tools
lua/blak/plugins/    base lazy.nvim specs
lua/blak/providers/  adapters for picker/package/provider-style features
lua/blak/extras/     optional modules
lua/blak/splash/     black-hole animation and dashboard integration
```

## Validation

Without Neovim:

```sh
make validate
```

With Neovim installed:

```sh
make smoke
```

Public CI should run both plus `stylua --check .` once Stylua is available.

## Adding an extra

Create a module under `lua/blak/extras/<group>/<name>.lua` and add it to the module list in `lua/blak/extras/init.lua`.

An extra can provide:

```lua
return {
  id = "lang.example",
  label = "Example",
  description = "What it does",
  treesitter = { "example" },
  mason = { "example-tool" },
  lsp = { servers = { example_ls = {} } },
  format = { formatters_by_ft = { example = { "examplefmt" } } },
  lint = { linters_by_ft = { example = { "examplelint" } } },
  snacks = { zen = { enabled = true } },
  keys = { { lhs = "<leader>ux", rhs = function() end, desc = "Example" } },
  plugins = { { "owner/plugin.nvim", opts = {} } },
}
```
