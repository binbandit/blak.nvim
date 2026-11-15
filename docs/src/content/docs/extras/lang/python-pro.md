---
title: Python Pro Extra
description: Configure lang.python-pro for BasedPyright, Ruff, VenvSelect, Python Treesitter, and debugpy and neotest-python with the debug and test extras.
---

`lang.python-pro` is the explicit power-user Python stack. It keeps project
policy in `pyproject.toml`, `ruff.toml`, `pyrightconfig.json`, and virtualenv
metadata, then wires Blak to the current best Neovim-facing tools.

Enable this instead of [`lang.python`](/extras/lang/python/). The basic extra
stays on Pyright with Black/isort so stable users do not get a surprise LSP or
formatter swap.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.python-pro",
    },
  },
}
```

Or enable it from Neovim:

```vim
:BlakExtras enable lang.python-pro
:BlakExtras disable lang.python
```

If both Python extras are enabled, `lang.python-pro` replaces the basic extra's
unchanged `pyright` and Black/isort defaults regardless of activation order.
Explicit user settings stay in effect, even if they match those defaults.
Remove an explicit `pyright` entry if you want only BasedPyright. Disabling
`lang.python` is still cleaner; installed tools are retained.

Because this extra adds a plugin, run:

```vim
:BlakExtras sync
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `python`, `requirements` |
| Mason | `ruff` (`basedpyright` is installed through the LSP server list) |
| LSP | `basedpyright`, `ruff` |
| Formatting | `ruff_organize_imports`, then `ruff_format`, for `python` |
| Plugin | `linux-cultist/venv-selector.nvim` |
| Keymap | `<leader>cv` opens `:VenvSelect` |

`basedpyright` handles Python language intelligence and type diagnostics. Ruff's
native language server handles lint diagnostics and code actions, while Conform
uses Ruff's import organizer and formatter for save-time formatting.

## Virtualenvs

Open a Python file, then use:

```vim
<leader>cv
```

VenvSelect searches common virtualenv locations with `fd`, updates the active
Python LSP configuration, and sets environment variables for child processes
inside Neovim. Blak configures it to use the built-in Snacks picker.

## Configure BasedPyright

Project config should live in `pyproject.toml` or `pyrightconfig.json`. Editor
settings still work under `lsp.servers.basedpyright`:

```lua
return {
  extras = {
    enabled = { "lang.python-pro" },
  },
  lsp = {
    servers = {
      basedpyright = {
        settings = {
          basedpyright = {
            analysis = {
              diagnosticMode = "workspace",
            },
          },
        },
      },
    },
  },
}
```

## Configure Ruff

Put lint and format policy in `pyproject.toml`, `ruff.toml`, or `.ruff.toml`.
Use `lsp.servers.ruff.init_options.settings` only for editor-specific settings:

```lua
return {
  extras = {
    enabled = { "lang.python-pro" },
  },
  lsp = {
    servers = {
      ruff = {
        init_options = {
          settings = {
            configurationPreference = "filesystemFirst",
          },
        },
      },
    },
  },
}
```

## Use Black and isort instead

If a project still wants the classic Black/isort path, override the Python
formatter entry and install the tools:

```lua
return {
  extras = {
    enabled = { "lang.python-pro" },
  },
  mason = {
    ensure_installed = { "black", "isort" },
  },
  format = {
    formatters_by_ft = {
      python = { "isort", "black" },
    },
  },
}
```

## Debugging and tests

Enable [`debug.dap`](/extras/debug/dap/) or
[`test.neotest`](/extras/test/neotest/) as well and `lang.python-pro` wires
them up for Python. Nothing is added unless both extras are on, and the enable order does
not matter.

| With | Contribution |
| --- | --- |
| `debug.dap` | Mason `debugpy`; plugin `mfussenegger/nvim-dap-python`, set up with Mason's `debugpy-adapter` |
| `test.neotest` | Plugin `nvim-neotest/neotest-python`, registered as a neotest adapter |

```lua
return {
  extras = {
    enabled = { "lang.python-pro", "debug.dap", "test.neotest" },
  },
}
```

These are the same adapters `lang.python` adds, so enabling both Python extras
still sets each one up once.

Run `:BlakExtras sync` after enabling them. If you already started a debug
session or ran a test in the current session, `:restart` so nvim-dap and
neotest load the new adapters.

- `<leader>dc` offers nvim-dap-python's `file`, `file:args`, `attach`, and
  `file:doctest` configurations.
- debugpy runs from Mason's own virtualenv, so the project does not need it.
  The program runs with `$VIRTUAL_ENV` or `$CONDA_PREFIX` (`<leader>cv`
  sets them), or a `venv`/`.venv` folder in the project. Without one it
  falls back to debugpy's interpreter, which has none of your packages.
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

Open a Python file and check `:checkhealth vim.lsp` for `basedpyright` and `ruff`.
