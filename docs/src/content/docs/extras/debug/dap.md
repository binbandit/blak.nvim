---
title: DAP Extra
description: Configure debug.dap for opt-in Debug Adapter Protocol workflows.
---

`debug.dap` installs [nvim-dap](https://github.com/mfussenegger/nvim-dap) and
[nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui). It provides the client
and UI; the language extras below add their debug adapters and launch
configurations when they are enabled too.

## Enable it

```lua
return {
  extras = {
    enabled = {
      "debug.dap",
    },
  },
}
```

Because this extra adds plugins, run:

```vim
:BlakExtras sync
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Plugin | `mfussenegger/nvim-dap` |
| Plugin | `rcarriga/nvim-dap-ui` |
| Dependencies | `nvim-nio` |
| Keymap | `<leader>db` toggles a breakpoint |
| Keymap | `<leader>dc` continues debugging |
| Keymap | `<leader>di` steps into |
| Keymap | `<leader>do` steps over |
| Keymap | `<leader>dO` steps out |
| Keymap | `<leader>dr` toggles the DAP REPL |
| Keymap | `<leader>dt` terminates the session |
| Keymap | `<leader>du` toggles dap-ui |

The keymaps appear in `:BlakKeys`.

## Use it

1. Put the cursor on a line and press `<leader>db` to set a breakpoint.
2. Press `<leader>dc` to start a session (or continue a stopped one).
3. When execution stops, step with `<leader>do`, `<leader>di`, and `<leader>dO`.
4. Press `<leader>du` to open dap-ui (scopes, stacks, breakpoints, watches,
   REPL, console). It does not open on its own, and it can be opened mid-session.
5. Press `<leader>dt` to end the session.

For a filetype without an adapter, `<leader>dc` reports
``No configuration found for `lua` `` (or your filetype).

## Language adapters

These language extras register an adapter and launch configurations when
`debug.dap` is enabled as well, in either order. Mason installs the debugger.

| Extra | Debugger | Configurations |
| --- | --- | --- |
| [`lang.go`](/extras/lang/go/#debugging-and-tests) | Delve (`delve`) | `Debug package`, `Debug package with arguments`, `Debug package tests` |
| [`lang.python`, `lang.python-pro`](/extras/lang/python/#debugging-and-tests) | debugpy through `nvim-dap-python` | `file`, `file:args`, `attach`, `file:doctest` |
| [`lang.rust`](/extras/lang/rust/#debugging) | CodeLLDB (`codelldb`) | `Debug binary (cargo build)` |

Run `:BlakExtras sync` after enabling them. nvim-dap reads adapters when it
first loads, so if you already debugged something in this session, `:restart`
to pick up a language enabled since.

nvim-dap also reads `.vscode/launch.json` from the project; see
`:help dap-launch.json`.

## Configure adapters

Adapters and launch configurations live in the `nvim-dap` spec's `opts`:
`adapters` is keyed by adapter name and `configurations` by filetype. Blak's
`config` function registers them when nvim-dap first loads, so debugging stays
lazy. Add your own for any other language in `user.lua`. JavaScript with
[js-debug](https://github.com/microsoft/vscode-js-debug)
(`:MasonInstall js-debug-adapter`):

```lua
return {
  extras = {
    enabled = { "debug.dap" },
  },
  plugins = {
    specs = {
      {
        "mfussenegger/nvim-dap",
        opts = {
          adapters = {
            ["pwa-node"] = {
              type = "server",
              port = "${port}",
              executable = { command = "js-debug-adapter", args = { "${port}" } },
            },
          },
          configurations = {
            javascript = {
              {
                type = "pwa-node",
                name = "Launch file",
                request = "launch",
                program = "${file}",
                cwd = "${workspaceFolder}",
              },
            },
          },
        },
      },
    },
  },
}
```

A `configurations` list replaces the one for that filetype, including a
language extra's. To add to an extra's list, use an `opts` function as in the
[Go](/extras/lang/go/#debugging-and-tests) and
[Rust](/extras/lang/rust/#debugging) examples. Setting `config` on this spec
replaces Blak's, and then no `opts` adapters are registered.

Check the result with `:checkhealth dap`, which lists each adapter and whether
its executable is found. See `:help dap-adapter`, `:help dap-configuration`,
and the
[nvim-dap adapter wiki](https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation).

## Disable it

Remove `"debug.dap"` from `extras.enabled` or run
`:BlakExtras disable debug.dap`, then restart Blak.
