---
title: TypeScript Extra
description: Configure lang.typescript for ts_ls, ESLint, Prettier, and JS/TS Treesitter support.
---

`lang.typescript` is the stable TypeScript and JavaScript stack. It keeps the
picker, keymaps, and editing model unchanged while adding language tooling for
JS, TS, JSX, TSX, JSON, and JSONC files.

Use this extra unless you intentionally want the experimental
[`lang.typescript-tsgo`](/extras/lang/typescript-tsgo/) extra instead.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.typescript",
    },
  },
}
```

You can also enable it from the command line:

```vim
:BlakExtras enable lang.typescript
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `javascript`, `typescript`, `tsx`, `jsdoc`, `json`, `jsonc` |
| Mason | `prettier`, `prettierd`, `eslint_d` |
| LSP | `ts_ls`, `eslint` |
| Formatting | `prettierd`, falling back to `prettier`, for JS/TS/JSON filetypes |
| Linting | `eslint_d` for JS/TS filetypes |

## Configure ts_ls and ESLint

Add LSP settings under the server names that the extra registers:

```lua
return {
  extras = {
    enabled = { "lang.typescript" },
  },
  lsp = {
    servers = {
      ts_ls = {
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
            },
          },
        },
      },
      eslint = {
        settings = {
          workingDirectory = { mode = "auto" },
        },
      },
    },
  },
}
```

Project ESLint and Prettier config files still live in the project. Blak only
installs and wires the editor tools.

## Configure formatting

The extra uses `prettierd` first and falls back to `prettier`. If you prefer the
plain `prettier` CLI, define the filetypes yourself in `user.lua`:

```lua
return {
  extras = {
    enabled = { "lang.typescript" },
  },
  format = {
    formatters_by_ft = {
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
    },
  },
}
```

## Disable JS/TS linting

To keep the LSP and formatting but stop `eslint_d` lint events for this stack,
set empty linter lists for the same filetypes:

```lua
return {
  extras = {
    enabled = { "lang.typescript" },
  },
  lint = {
    linters_by_ft = {
      javascript = {},
      javascriptreact = {},
      typescript = {},
      typescriptreact = {},
    },
  },
}
```

## Install and verify

After enabling the extra, run:

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a TypeScript file and check `:LspInfo` for `ts_ls` and `eslint`.
