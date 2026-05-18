---
title: TypeScript Tsgo Extra
description: Configure lang.typescript-tsgo for the experimental tsgo LSP with ESLint and Prettier.
---

`lang.typescript-tsgo` is the TypeScript and JavaScript stack that registers the
experimental `tsgo` language server instead of `ts_ls`.

Enable this extra instead of [`lang.typescript`](/extras/lang/typescript/), not
alongside it. If `lang.typescript` is enabled in the extras state file, disable
it with `:BlakExtras disable lang.typescript`.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.typescript-tsgo",
    },
  },
}
```

Or toggle it interactively:

```vim
:BlakExtras enable lang.typescript-tsgo
:BlakExtras disable lang.typescript
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `javascript`, `typescript`, `tsx`, `jsdoc`, `json`, `jsonc` |
| Mason | `prettier`, `prettierd`, `eslint_d` |
| LSP | `tsgo`, `eslint` |
| Formatting | `prettierd`, falling back to `prettier`, for JS/TS/JSON filetypes |
| Linting | `eslint_d` for JS/TS filetypes |
| Apply hook | Removes `ts_ls` from the merged config before future setup |

The extra registers the `tsgo` LSP name. It does not add a Mason package for the
server itself, so use `:LspInfo` and `:BlakDoctor` to confirm your local setup
can start it.

## Configure tsgo

Put `tsgo` settings under `lsp.servers.tsgo`:

```lua
return {
  extras = {
    enabled = { "lang.typescript-tsgo" },
  },
  lsp = {
    servers = {
      tsgo = {
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

## Configure formatting and linting

This extra uses the same formatter and linter defaults as
`lang.typescript`. Override the filetype entries before the extra fills them:

```lua
return {
  extras = {
    enabled = { "lang.typescript-tsgo" },
  },
  format = {
    formatters_by_ft = {
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
    },
  },
  lint = {
    linters_by_ft = {
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
    },
  },
}
```

## Switching from ts_ls

When switching from `lang.typescript`, restart Neovim after disabling it. The
extra removes `ts_ls` from future setup, but an LSP client that already attached
in the current session will keep running until it is stopped or Neovim exits.

## Install and verify

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Then open a TypeScript file and check `:LspInfo` for `tsgo`.
