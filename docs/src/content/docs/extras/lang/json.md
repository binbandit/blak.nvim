---
title: JSON Extra
description: Configure lang.json for jsonls with SchemaStore schemas and Prettier.
---

`lang.json` adds JSON support through jsonls, wired to the
[SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim) catalog for
validation and completion against well-known schemas (`package.json`,
`tsconfig.json`, and more), with Prettier formatting.

`lang.typescript` already contributes JSON Treesitter and Prettier formatting;
the distinct value here is the JSON language server with SchemaStore, which no
other extra provides.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.json",
    },
  },
}
```

Because this extra adds a plugin (SchemaStore.nvim), run:

```vim
:BlakExtras sync
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `json`, `jsonc` |
| Mason | `prettier`, `prettierd` |
| LSP | `jsonls` with SchemaStore schemas |
| Formatting | `prettierd` (fallback `prettier`) for `json`, `jsonc` |
| Plugin | `b0o/SchemaStore.nvim` |

`jsonls` installs automatically through Mason (package `json-lsp`).

## How schemas load

SchemaStore.nvim is pulled in lazily from the server's `before_init` hook, so
the schema catalog only loads when jsonls actually starts. JSON validation is
enabled by default.

## Install and verify

```vim
:BlakExtras sync
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a `package.json` and confirm completion and validation against its schema,
and check `:LspInfo` for `json-lsp`.
