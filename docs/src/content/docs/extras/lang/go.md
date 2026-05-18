---
title: Go Extra
description: Configure lang.go for gopls, goimports, gofumpt, golangci-lint, and Go Treesitter support.
---

`lang.go` adds Go language support while leaving project configuration in the
repository. Use `go.mod`, `golangci.yml`, and standard Go toolchain files for
project policy.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.go",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable lang.go
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `go`, `gomod`, `gosum`, `gowork` |
| Mason | `goimports`, `gofumpt`, `golangci-lint` |
| LSP | `gopls` |
| Formatting | `goimports`, then `gofumpt`, for `go` |
| Linting | `golangcilint` for `go` |

## Configure gopls

Add `gopls` settings under `lsp.servers.gopls`:

```lua
return {
  extras = {
    enabled = { "lang.go" },
  },
  lsp = {
    servers = {
      gopls = {
        settings = {
          gopls = {
            staticcheck = true,
            analyses = {
              unusedparams = true,
              shadow = true,
            },
          },
        },
      },
    },
  },
}
```

## Configure formatting

The default import and formatting chain is:

```lua
return {
  extras = {
    enabled = { "lang.go" },
  },
  format = {
    formatters_by_ft = {
      go = { "goimports", "gofumpt" },
    },
  },
}
```

If your team only wants `gofmt` through LSP, override the Go formatter entry:

```lua
return {
  extras = {
    enabled = { "lang.go" },
  },
  format = {
    formatters_by_ft = {
      go = { lsp_format = "fallback" },
    },
  },
}
```

## Configure linting

The extra maps Go files to nvim-lint's `golangcilint` linter. Disable it with
an empty list when a project uses only LSP diagnostics:

```lua
return {
  extras = {
    enabled = { "lang.go" },
  },
  lint = {
    linters_by_ft = {
      go = {},
    },
  },
}
```

## Install and verify

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a Go file and check `:LspInfo` for `gopls`.
