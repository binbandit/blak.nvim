---
title: Customize
description: A user.lua override file is the entire customization surface.
---

Blak's customization model is intentionally small. There is **one place** to override defaults — `lua/blak/user.lua` — and one command to manage optional modules — `:BlakExtras`.

## The user.lua override

Copy the example file:

```sh
cp ~/.config/blak/lua/blak/user.example.lua ~/.config/blak/lua/blak/user.lua
```

Then edit it. The file returns a table that is deep-merged into the defaults:

```lua
return {
  picker = { provider = "fff" },
  ui = {
    splash = {
      enabled = true,
      animate = true,
      loop = true,
    },
  },
  extras = {
    enabled = { "lang.typescript", "git.lazygit" },
  },
}
```

`user.lua` is gitignored by default so your local changes stay local, but Blak ships a picker ignore override so file tools can still find it.

## Override patterns

### Switch picker

```lua
return {
  picker = { provider = "snacks" }, -- fff | snacks | telescope | fzf_lua
}
```

### Switch explorer

```vim
:BlakExtras enable editor.snacks-explorer
```

Or set the provider directly if you are already managing Snacks options yourself:

```lua
return {
  explorer = { provider = "snacks" }, -- oil | snacks
  snacks = { explorer = { enabled = true } },
}
```

### Disable the splash animation

```lua
return {
  ui = {
    splash = { animate = false }, -- or { enabled = false } to remove entirely
  },
}
```

### Add Mason tools or treesitter parsers

```lua
return {
  mason = {
    ensure_installed = { "stylua", "shfmt", "tree-sitter-cli", "buf" },
  },
  treesitter = {
    ensure_installed = { "bash", "lua", "markdown", "proto" },
  },
}
```

### Tune LSP diagnostics

```lua
return {
  lsp = {
    diagnostics = {
      virtual_text = false,
      virtual_lines = true,
    },
  },
}
```

See the [config schema](/reference/schema/) for the full list of valid keys and the [defaults reference](/reference/defaults/) for what you're overriding.

## Extras over config

If you find yourself adding plugins inside `user.lua`, consider whether it should be an extra instead:

```vim
:BlakExtras
:BlakExtras enable lang.python
:BlakExtras disable git.lazygit
```

State is stored in `stdpath('state')/blak/extras.json`, not in the repo. A fresh clone with the same `NVIM_APPNAME` reuses that state; a fresh install under a new `NVIM_APPNAME` starts from your config defaults.

Need an extra that doesn't exist yet? See the [Contributing guide](/contributing/#adding-an-extra) — they're small and self-contained.

## When to fork

The fork test is simple: if you want to change the *contract* — different picker by default, different completion engine, custom splash — fork. If you want to change *your* setup, use `user.lua` or an extra.
