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

## Virtualenvs

Pyright uses the `python` on `$PATH`, so a project `.venv` is only picked up
when it is activated before Neovim starts. Otherwise imports from the venv show
up as `Import "..." could not be resolved`. Point Pyright at the venv in the
project instead:

```toml
# pyproject.toml
[tool.pyright]
venvPath = "."
venv = ".venv"
```

For a one-off session, `:LspPyrightSetPythonPath .venv/bin/python` does the
same. `lang.python-pro` adds a virtualenv picker if you switch environments
often.

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

## Debugging and tests

Enable [`debug.dap`](/extras/debug/dap/) or
[`test.neotest`](/extras/test/neotest/) as well and `lang.python` wires them up for
Python. Nothing is added unless both extras are on, and the enable order does
not matter.

| With | Contribution |
| --- | --- |
| `debug.dap` | Mason `debugpy`; plugin `mfussenegger/nvim-dap-python`, set up with Mason's `debugpy-adapter` |
| `test.neotest` | Plugin `nvim-neotest/neotest-python`, registered as a neotest adapter |

```lua
return {
  extras = {
    enabled = { "lang.python", "debug.dap", "test.neotest" },
  },
}
```

Run `:BlakExtras sync` after enabling them. If you already started a debug
session or ran a test in the current session, `:restart` so nvim-dap and
neotest load the new adapters.

- `<leader>dc` offers nvim-dap-python's `file`, `file:args`, `attach`, and
  `file:doctest` configurations.
- debugpy runs from Mason's own virtualenv, so the project does not need it.
  The program runs with `$VIRTUAL_ENV`, `$CONDA_PREFIX`, or a `venv`/`.venv`
  folder in the project. Without one it falls back to debugpy's
  interpreter, which has none of your packages.
- `<leader>Tn`, `<leader>Tf`, and `<leader>Td` run, or debug, tests with pytest
  when the project's Python has it, otherwise with Django's runner or
  `unittest`.

Pass [neotest-python options](https://github.com/nvim-neotest/neotest-python)
under its adapter name:

```lua
return {
  plugins = {
    specs = {
      {
        "nvim-neotest/neotest",
        opts = {
          adapters = {
            ["neotest-python"] = { dap = { justMyCode = false } },
          },
        },
      },
    },
  },
}
```

Disabling either extra removes the adapter after `:restart`; Mason keeps
`debugpy` installed until you run `:MasonUninstall debugpy`.

## Install and verify

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a Python file and check `:checkhealth vim.lsp` for `pyright` and `ruff`.
