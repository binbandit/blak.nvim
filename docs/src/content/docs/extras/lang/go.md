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

## Debugging and tests

Enable [`debug.dap`](/extras/debug/dap/) or
[`test.neotest`](/extras/test/neotest/) as well and `lang.go` wires them up for
Go. Nothing is added unless both extras are on, and the enable order does not
matter.

| With | Contribution |
| --- | --- |
| `debug.dap` | Mason `delve`; a `go` adapter that runs `dlv dap` |
| `debug.dap` | Launch configurations: `Debug package`, `Debug package with arguments`, `Debug package tests` |
| `test.neotest` | Plugin `fredrikaverpil/neotest-golang`, registered as a neotest adapter |

```lua
return {
  extras = {
    enabled = { "lang.go", "debug.dap", "test.neotest" },
  },
}
```

Run `:BlakExtras sync` after enabling them. If you already started a debug
session or ran a test in the current session, `:restart` so nvim-dap and
neotest load the new adapters.

- `<leader>dc` in a Go file asks for a launch configuration. The package is the
  current file's directory, and `dlv` runs from that package's `go.mod` folder,
  so debugging works when Neovim was started in a parent folder.
- Program output goes to the DAP REPL and dap-ui console.
- `<leader>Tn`, `<leader>Tf`, and `<leader>Td` run, or debug, Go tests through
  neotest-golang. Test debugging uses the same Delve adapter, so
  `leoluz/nvim-dap-go` is not needed.

Change the test runner or other
[neotest-golang options](https://fredrikaverpil.github.io/neotest-golang/config/)
under its adapter name; Blak's settings for the rest stay in place:

```lua
return {
  mason = {
    ensure_installed = { "gotestsum" },
  },
  plugins = {
    specs = {
      {
        "nvim-neotest/neotest",
        opts = {
          adapters = {
            ["neotest-golang"] = { runner = "gotestsum" },
          },
        },
      },
    },
  },
}
```

Add a launch configuration of your own, here attaching to a running process:

```lua
return {
  plugins = {
    specs = {
      {
        "mfussenegger/nvim-dap",
        opts = function(_, opts)
          table.insert(opts.configurations.go, {
            type = "go",
            name = "Attach to process",
            request = "attach",
            mode = "local",
            processId = require("dap.utils").pick_process,
          })
        end,
      },
    },
  },
}
```

`opts = { configurations = { go = { ... } } }` replaces the Go list instead.
Disabling either extra removes the adapter after `:restart`; Mason keeps
`delve` installed until you run `:MasonUninstall delve`.

## Install and verify

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a Go file and check `:checkhealth vim.lsp` for `gopls`. With the debug
and test extras, `:checkhealth dap` lists the `go` adapter and
`:checkhealth neotest-golang` checks `go`, `dlv`, and the Go parser. Its
optional `dap-go is not available` warning is expected: Blak debugs Go tests
with its own Delve adapter.
