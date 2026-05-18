---
title: Lua Extra
description: Configure the lang.lua extra for lua_ls, stylua, and Lua Treesitter support.
---

`lang.lua` is the Lua development extra. It is useful for Blak itself, Neovim
plugins, and any local Lua module work.

Stock Blak already includes the same Lua basics in its defaults, so enabling
this extra is mostly a way to keep your language stack explicit in
`lua/blak/user.lua`.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.lua",
    },
  },
}
```

You can also enable it from the extras UI:

```vim
:BlakExtras enable lang.lua
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `lua`, `luadoc` |
| Mason | `stylua` |
| LSP | `lua_ls` |
| Formatting | `stylua` for `lua` |

## Configure lua_ls

The extra registers `lua_ls`. Add server settings under `lsp.servers.lua_ls` in
`user.lua` when your workspace needs extra globals or library paths:

```lua
return {
  extras = {
    enabled = { "lang.lua" },
  },
  lsp = {
    servers = {
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim", "describe", "it" },
            },
          },
        },
      },
    },
  },
}
```

## Configure formatting

`stylua` is the formatter for Lua files. If you set a Lua formatter entry in
`user.lua`, Blak keeps your entry instead of replacing it with the extra's
default:

```lua
return {
  extras = {
    enabled = { "lang.lua" },
  },
  format = {
    formatters_by_ft = {
      lua = { "stylua" },
    },
  },
}
```

Put project-specific style in `.stylua.toml`; Blak just wires the formatter.

## Install and verify

After enabling the extra, run:

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a Lua file and check `:LspInfo` to confirm `lua_ls` attached.
