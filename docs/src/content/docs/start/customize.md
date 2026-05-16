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

`user.lua` is gitignored by default — your local changes stay local.

## Override patterns

### Switch picker

```lua
return {
  picker = { provider = "snacks" }, -- fff | snacks | telescope | fzf_lua
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
:BlakExtras list
:BlakExtras enable lang.python
:BlakExtras disable git.lazygit
```

State is stored in `stdpath('state')/blak/extras.json`, not in the repo — so multiple machines, multiple checkouts, or a fresh clone all start from the same defaults.

Need an extra that doesn't exist yet? See the [Contributing guide](/contributing/#adding-an-extra) — they're small and self-contained.

## When to fork

The fork test is simple: if you want to change the *contract* — different picker by default, different completion engine, custom splash — fork. If you want to change *your* setup, use `user.lua` or an extra.
