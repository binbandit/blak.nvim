---
title: Mason
description: External tool installation — LSP servers, formatters, linters, parsers.
---

Mason installs anything that isn't a Neovim plugin — LSP servers, formatters, linters, the tree-sitter CLI, debuggers. Blak wires it so the tools an extra needs install automatically when you enable the extra.

Tools setup: [`lua/blak/core/tools.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/tools.lua). Plugin spec: [`lua/blak/plugins/lsp.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/plugins/lsp.lua).

## Defaults

```lua
mason = {
  automatic_install = true,
  ensure_installed = {
    "stylua",
    "shfmt",
    "tree-sitter-cli",
  },
}
```

Just enough to make first-launch useful: a Lua formatter (for the config files Blak ships), a shell formatter, and the CLI for compiling Treesitter parsers.

Language extras add to this list automatically — see each extra's "Mason" row in [Extras](/guide/extras/).

## Automatic install

When `automatic_install = true`, Blak calls `tools.ensure()` shortly after startup:

1. Wait for the Mason registry to refresh.
2. Look up the configured package list (`mason.ensure_installed` + extras).
3. Install anything missing.
4. Skip anything already installed (silent), or log it if called with `force = true`.

Missing packages don't error — they warn so a typo or a Mason-renamed tool doesn't block startup.

## Manual install

```vim
:BlakToolsInstall      " force, logs already-installed packages too
:Mason                 " open Mason's UI
:MasonInstall <pkg>    " install one explicitly
```

Use `:BlakToolsInstall` after enabling a new extra so its tools land in one shot.

## Disabling automatic install

```lua
return {
  mason = { automatic_install = false },
}
```

You'll need to install tools yourself with `:BlakToolsInstall` or `:Mason`.

## Adding a tool

In `user.lua`:

```lua
return {
  mason = {
    ensure_installed = { "stylua", "shfmt", "tree-sitter-cli", "buf", "yamlfmt" },
  },
}
```

> Like other lists, this replaces the default wholesale. Include the defaults you still want.

Or via an extra — preferred, because the install is rolled back when you disable.

## Mason UI

The Mason UI uses your `ui.winborder` (default `"rounded"`). Open with `:Mason`. From there:

- `i` install
- `u` update
- `X` uninstall
- `?` help

## Where things live

```
$XDG_DATA_HOME/<appname>/mason/        " for Blak, usually ~/.local/share/blak/mason
  ├── packages/<name>/                 " installed binaries / scripts
  └── bin/                             " shims added to runtime $PATH
```

`mason-lspconfig` bridges between Mason package names (`lua-language-server`) and lspconfig server names (`lua_ls`). The `ensure_installed` list it sends to Mason is derived from `lsp.servers` keys.
