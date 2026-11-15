---
title: Neotest Extra
description: Configure test.neotest as a base for language-specific test adapters.
---

`test.neotest` installs [neotest](https://github.com/nvim-neotest/neotest), an
extensible test runner framework. The extra provides the framework and
discoverable keymaps; the language extras below add their test adapters when
they are enabled too.

## Enable it

```lua
return {
  extras = {
    enabled = {
      "test.neotest",
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
| Plugin | `nvim-neotest/neotest` |
| Dependencies | `nvim-nio`, `plenary.nvim` (used by adapters such as neotest-golang) |
| Keymap | `<leader>Tn` runs the nearest test |
| Keymap | `<leader>Tf` runs the current file |
| Keymap | `<leader>Td` debugs the nearest test through DAP |
| Keymap | `<leader>Ts` toggles the test summary |
| Keymap | `<leader>To` opens test output |
| Keymap | `<leader>TO` toggles the output panel |

The keymaps appear in `:BlakKeys`.

## Language adapters

These language extras add a neotest adapter when `test.neotest` is enabled as
well, in either order:

| Extra | Adapter |
| --- | --- |
| [`lang.go`](/extras/lang/go/#debugging-and-tests) | [neotest-golang](https://github.com/fredrikaverpil/neotest-golang) |
| [`lang.python`, `lang.python-pro`](/extras/lang/python/#debugging-and-tests) | [neotest-python](https://github.com/nvim-neotest/neotest-python) |

Run `:BlakExtras sync` after enabling them. neotest reads its adapters when it
first loads, so if you already ran a test in this session, `:restart` to pick
up a language enabled since; the run keymaps say so. With no adapter at all
they warn `Neotest has no adapters` instead of running anything.
[`lang.rust`](/extras/lang/rust/#debugging) has no adapter.

## Add or change adapters

`opts.adapters` on the `neotest` spec maps an adapter's module name to its
options. Blak calls `require(name)(options)` when neotest loads, so an adapter
is set up once however many extras ask for it, and a user spec merges with an
extra's options instead of adding a second copy. Set an entry to `false` to
turn that adapter off.

Add another adapter the same way, here
[neotest-jest](https://github.com/nvim-neotest/neotest-jest). Adapters find
tests with the language's Treesitter parser, so enable the matching `lang.*`
extra too; `lang.typescript` installs the JavaScript one:

```lua
return {
  extras = {
    enabled = { "test.neotest", "lang.typescript" },
  },
  plugins = {
    specs = {
      {
        "nvim-neotest/neotest",
        dependencies = { "nvim-neotest/neotest-jest" },
        opts = {
          adapters = {
            ["neotest-jest"] = { jestCommand = "npx jest" },
          },
        },
      },
    },
  },
}
```

Adapter objects work too: `table.insert(opts.adapters, require("neotest-jest")({}))`
inside an `opts = function(_, opts) ... end` keeps them as they are. Setting
`config` on this spec replaces Blak's, and then you must build the adapter list
yourself.

## Debug tests

`<leader>Td` runs the nearest test through the Debug Adapter Protocol. It needs
`debug.dap` enabled; without nvim-dap it warns instead of running. Go and
Python tests use the adapters their language extras register for `debug.dap`.

## Disable it

Remove `"test.neotest"` from `extras.enabled` or run
`:BlakExtras disable test.neotest`, then restart Blak.
