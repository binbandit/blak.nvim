---
title: C/C++ Extra
description: Configure lang.c for clangd, clang-format, and C/C++ Treesitter support.
---

`lang.c` adds C and C++ language support through clangd, with clang-format for
formatting. Project configuration stays in the repository — use
`.clang-format`, `.clangd`, and `compile_commands.json` for project policy.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.c",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable lang.c
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `c`, `cpp` |
| Mason | `clang-format` |
| LSP | `clangd` |
| Formatting | `clang_format` for `c`, `cpp`, `objc`, `objcpp`, `cuda` |

clangd installs automatically through Mason; only the standalone formatter
needs a Mason entry.

## Configure clangd

Add `clangd` settings under `lsp.servers.clangd`:

```lua
return {
  extras = { enabled = { "lang.c" } },
  lsp = {
    servers = {
      clangd = {
        cmd = { "clangd", "--background-index", "--clang-tidy" },
      },
    },
  },
}
```

clangd ships its own clang-tidy integration, so Blak does not register a
separate linter for C/C++.

## Install and verify

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a C or C++ file and check `:LspInfo` for `clangd`. clangd works best with
a `compile_commands.json` (generate it with CMake's
`CMAKE_EXPORT_COMPILE_COMMANDS` or with Bear).
