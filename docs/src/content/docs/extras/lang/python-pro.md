---
title: Python Pro Extra
description: Configure lang.python-pro for BasedPyright, Ruff, VenvSelect, debugpy, and Python Treesitter support.
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

If both Python extras are enabled, `lang.python-pro` removes the basic extra's
default `pyright`, Black/isort formatter, and nvim-lint Ruff entry when they are
still unchanged. Disabling `lang.python` is still cleaner.

Because this extra adds a plugin, run:

```vim
:BlakExtras sync
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `python`, `requirements` |
| Mason | `ruff`, `debugpy` (`basedpyright` is installed through the LSP server list) |
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

## Debug and test adapters

`debugpy` is installed for Python debugging, but Blak keeps the DAP UI and test
runner as separate explicit extras. Enable `debug.dap` when you want debug
keymaps and add `nvim-dap-python` in `plugins.specs`:

```lua
return {
  extras = {
    enabled = { "lang.python-pro", "debug.dap" },
  },
  plugins = {
    specs = {
      {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
          require("dap-python").setup("debugpy-adapter")
        end,
      },
    },
  },
}
```

Use `test.neotest` plus `neotest-python` when you want an in-editor Python test
runner.

## Install and verify

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a Python file and check `:LspInfo` for `basedpyright` and `ruff`.
