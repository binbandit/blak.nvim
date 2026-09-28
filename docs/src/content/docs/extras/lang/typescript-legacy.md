---
title: Legacy TypeScript Extra
description: Configure lang.typescript-legacy for ts_ls, ESLint, Prettier, and JS/TS Treesitter support.
---

`lang.typescript-legacy` is the optional `ts_ls` TypeScript and JavaScript stack. It keeps the
picker, keymaps, and editing model unchanged while adding language tooling for
JS, TS, JSX, TSX, JSON, and JSONC files.

Use this when a project needs `ts_ls` or TypeScript server plugins. The standard
[`lang.typescript`](/extras/lang/typescript/) extra uses native TypeScript 7.
Disable `lang.typescript` and `lang.typescript-tsgo` before enabling the legacy
extra, and restart after switching. Remove explicit `lsp.servers.tsc` entries
as well if you want only `ts_ls`.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.typescript-legacy",
    },
  },
}
```

You can also enable it from the command line:

```vim
:BlakExtras enable lang.typescript-legacy
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
    enabled = { "lang.typescript-legacy" },
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

## TypeScript SDK and initialization errors

`ts_ls` wraps TypeScript's `tsserver.js`. The language server executable alone
is not enough. TypeScript 7 removed that file; the legacy extra needs a
compatible SDK that still supplies it.

Before initializing each client, Blak searches the workspace and its ancestors
for TypeScript in `node_modules`, Yarn/pnpm SDKs, or the older PnPify SDK
directory. It falls back to the TypeScript bundled with Mason's
`typescript-language-server` package, using your configured Mason install root.
This also lets a project-local language server use Mason's SDK when it has no
TypeScript dependency of its own. Project dependencies are never modified.

If you see "Could not find a valid TypeScript installation":

1. Run `:BlakToolsInstall`. Blak refreshes the registry and repairs an installed
   Mason package if its TypeScript SDK is missing `tsserver.js` or package metadata.
2. Wait for the installation to finish in `:Mason`, then restart Neovim.
3. Run `:BlakDoctor` to check Mason's fallback and `:LspInfo` to check the client.

Automatic installation performs the same repair when
`mason.automatic_install = true`. Set it to `false` for manual tool management.
If the registry cannot refresh or the install fails, inspect `:MasonLog` and retry.

To select an SDK yourself, set
`lsp.servers.ts_ls.init_options.tsserver.path` to the full path of a compatible
`tsserver.js` or its `lib` directory. Blak preserves explicit `path`,
`fallbackPath`, and `before_init` overrides. Remove the override to restore
Blak's SDK resolution. Existing clients need a restart after changing SDKs.

## Configure formatting

The extra uses `prettierd` first and falls back to `prettier`. If you prefer the
plain `prettier` CLI, define the filetypes yourself in `user.lua`:

```lua
return {
  extras = {
    enabled = { "lang.typescript-legacy" },
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
