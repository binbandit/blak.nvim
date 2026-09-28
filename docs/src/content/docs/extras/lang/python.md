---
title: Python Extra
description: Configure lang.python for Pyright, Ruff, Black, isort, and Python Treesitter support.
---

`lang.python` adds the usual Python editing stack without changing project
policy. Your `pyproject.toml`, `ruff.toml`, or tool-specific config files remain
the source of truth for formatting and lint rules.

For a more opinionated power-user stack with BasedPyright, Ruff formatting,
virtualenv selection, and debugpy tooling, use
[`lang.python-pro`](/extras/lang/python-pro/) instead.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.python",
    },
  },
}
```

Or enable it from Neovim:

```vim
:BlakExtras enable lang.python
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `python` |
| Mason | `black`, `isort`, `ruff` |
| LSP | `pyright`, `ruff` |
| Formatting | `isort`, then `black`, for `python` |
| Linting | Ruff language server diagnostics; no duplicate nvim-lint process |

## Configure Pyright and Ruff

Use `lsp.servers.pyright` and `lsp.servers.ruff` for server settings:

```lua
return {
  extras = {
    enabled = { "lang.python" },
  },
  lsp = {
    servers = {
      pyright = {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
            },
          },
        },
      },
      ruff = {
        init_options = {
          settings = {
            lineLength = 100,
          },
        },
      },
    },
  },
}
```

## Configure formatting

The default order is imports first, then code formatting:

```lua
return {
  extras = {
    enabled = { "lang.python" },
  },
  format = {
    formatters_by_ft = {
      python = { "isort", "black" },
    },
  },
}
```

To let Ruff lint but disable formatting for Python, use an empty formatter
list with LSP formatting disabled for that filetype. An empty list alone still
permits the global LSP fallback:

```lua
return {
  extras = {
    enabled = { "lang.python" },
  },
  format = {
    formatters_by_ft = {
      python = { lsp_format = "never" },
    },
  },
}
```

## Configure linting

Ruff LSP supplies diagnostics. If you intentionally want a second Ruff run
through nvim-lint, add it explicitly:

```lua
return {
  extras = {
    enabled = { "lang.python" },
  },
  lint = {
    linters_by_ft = {
      python = { "ruff" },
    },
  },
}
```

Remove that entry to return to LSP-only diagnostics.

## Install and verify

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a Python file and check `:LspInfo` for `pyright` and `ruff`.
