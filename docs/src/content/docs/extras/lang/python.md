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
| Linting | `ruff` for `python` |

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

To let Ruff lint but stop format-on-save for Python, define an empty formatter
list for Python:

```lua
return {
  extras = {
    enabled = { "lang.python" },
  },
  format = {
    formatters_by_ft = {
      python = {},
    },
  },
}
```

## Configure linting

The extra wires `ruff` through nvim-lint. Set an empty list if you want only the
Ruff LSP diagnostics:

```lua
return {
  extras = {
    enabled = { "lang.python" },
  },
  lint = {
    linters_by_ft = {
      python = {},
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

Open a Python file and check `:LspInfo` for `pyright` and `ruff`.
