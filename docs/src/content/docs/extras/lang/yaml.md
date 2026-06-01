---
title: YAML Extra
description: Configure lang.yaml for yaml-language-server with SchemaStore schemas and Prettier.
---

`lang.yaml` adds YAML support through yaml-language-server, wired to the
[SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim) schema catalog for
validation and completion against well-known schemas (GitHub Actions, Kubernetes,
Compose, and more), with Prettier formatting.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.yaml",
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
| Treesitter | `yaml` |
| Mason | `prettier`, `prettierd` |
| LSP | `yamlls` with SchemaStore schemas |
| Formatting | `prettierd` (fallback `prettier`) for `yaml` |
| Plugin | `b0o/SchemaStore.nvim` |

`yamlls` installs automatically through Mason (package `yaml-language-server`).

## How schemas load

SchemaStore.nvim is pulled in lazily from the server's `before_init` hook, so
the schema catalog only loads when yamlls actually starts. The extra disables
the server's built-in schema store in favor of SchemaStore.nvim. To pin a
schema to a path, add it under `lsp.servers.yamlls.settings.yaml.schemas`:

```lua
return {
  extras = { enabled = { "lang.yaml" } },
  lsp = {
    servers = {
      yamlls = {
        settings = {
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            },
          },
        },
      },
    },
  },
}
```

## Install and verify

```vim
:BlakExtras sync
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a `.yaml` file and check `:LspInfo` for `yaml-language-server`.
