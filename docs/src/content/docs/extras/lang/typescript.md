---
title: TypeScript Extra
description: Configure lang.typescript for the TypeScript 7 native LSP with ESLint and Prettier.
---

`lang.typescript` is the standard TypeScript and JavaScript stack. It uses
TypeScript 7's native `tsc` language server, ESLint, and Prettier for JS, TS,
JSX, TSX, JSON, and JSONC files.

For projects that need `ts_ls` or TypeScript server plugins, use the optional
[`lang.typescript-legacy`](/extras/lang/typescript-legacy/) extra instead.
The former [`lang.typescript-tsgo`](/extras/lang/typescript-tsgo/) beta extra
is a compatibility alias for this stack.

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

Or toggle it interactively:

```vim
:BlakExtras enable lang.typescript
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `javascript`, `typescript`, `tsx`, `jsdoc`, `json` |
| Mason | `prettier`, `prettierd` |
| LSP | `tsc`, `eslint` |
| Formatting | `prettierd`, falling back to `prettier`, for JS/TS/JSON filetypes |
| Linting | ESLint diagnostics come from the `eslint` language server |
| Stack selection | Replaces defaults contributed by `lang.typescript-legacy`, preserving explicit user settings |

Mason installs `tsc` through the LSP server list. The pinned nvim-lspconfig
configuration looks for a compatible native compiler in the project first,
then on `PATH`. A TypeScript 6 project dependency can stay in place; Mason's
TypeScript 7 supplies the editor server without changing project dependencies.
See [upstream's server configuration](https://github.com/neovim/nvim-lspconfig/blob/master/lsp/tsc.lua).

## Configure tsc

Put native TypeScript settings under `lsp.servers.tsc`. Its settings namespace
is `js/ts`:

```lua
return {
  extras = {
    enabled = { "lang.typescript" },
  },
  lsp = {
    servers = {
      tsc = {
        settings = {
          ["js/ts"] = {
            inlayHints = {
              parameterNames = { enabled = "all" },
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

The extra uses `prettierd` first, falling back to `prettier`. Override the
filetype entries in `user.lua` to prefer the plain CLI:

```lua
return {
  extras = {
    enabled = { "lang.typescript" },
  },
  format = {
    formatters_by_ft = {
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
    },
  },
}
```

ESLint diagnostics come from the `eslint` language server, so no nvim-lint entry
is registered. See [Using eslint_d
anyway](/guide/linting/#using-eslint_d-anyway) if you want the standalone daemon
as well.

## Updating an existing TypeScript setup

`lang.typescript` now uses native `tsc` in place of `ts_ls`. Run
`:BlakToolsInstall`, wait for installation, and restart. Review any old
`lsp.servers.ts_ls` settings: they remain explicit user configuration and can
start a second server. Remove them when switching to `tsc`; its settings use
the `js/ts` namespace shown above rather than the old `ts_ls` schema.

To retain `ts_ls`, replace `lang.typescript` with `lang.typescript-legacy` in
`user.lua` or the extras UI, then restart. Disable the compatibility alias too
if it is enabled. Installed Mason tools remain until you remove them.

If both native and legacy extras are enabled, the native stack replaces only
unchanged defaults contributed by the legacy extra, regardless of activation
order. Explicit user servers and formatter settings stay in effect. Prefer
enabling one stack so your selection is clear.

## Install and verify

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Wait for installation, restart, then open a TypeScript file and check `:LspInfo`
for `tsc` and `eslint`. To disable this stack, remove it from `user.lua` or run
`:BlakExtras disable lang.typescript`, then restart. Disable the compatibility
alias too if it is enabled.
