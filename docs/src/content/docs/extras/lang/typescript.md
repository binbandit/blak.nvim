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
| Treesitter | `javascript`, `typescript`, `tsx`, `jsdoc`, `json` |
| Mason | `prettier`, `prettierd` |
| LSP | `ts_ls`, `eslint` |
| Formatting | `prettierd`, falling back to `prettier`, for JS/TS/JSON filetypes |
| Linting | ESLint diagnostics come from the `eslint` language server |

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

## Where ESLint diagnostics come from

The extra registers no nvim-lint entries. ESLint diagnostics come from the
`eslint` language server, which Mason installs as
`vscode-eslint-language-server` because the extra lists `eslint` under
`lsp.servers`.

To run the standalone `eslint_d` daemon in addition, see [Using eslint_d
anyway](/guide/linting/#using-eslint_d-anyway). To take manual control of which
servers start, see [Disabling automatic
enable](/guide/lsp/#disabling-automatic-enable).

## Install and verify

After enabling the extra, run:

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a TypeScript file and check `:LspInfo` for `ts_ls` and `eslint`.
