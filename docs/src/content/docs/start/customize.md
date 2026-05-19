---
title: Customize
description: Simple user.lua config first, full Lua control when you need it.
---

Blak has one config file and one optional-module command:

```vim
:BlakConfig
:BlakExtras
```

`:BlakConfig` opens `lua/blak/user.lua`. If it does not exist yet, Blak creates
it from a small example. From a shell, the same setup is:

```sh
cp ~/.config/blak/lua/blak/user.example.lua ~/.config/blak/lua/blak/user.lua
```

## The easy path

Most customization should be this boring:

```lua
---@type blak.UserConfig
return {
  picker = { provider = "fff" },
  completion = { super_tab = true },
  terminal = { toggle_key = "<C-/>" },
  extras = { enabled = { "lang.typescript", "git.lazygit" } },
}
```

That table is deep-merged into Blak's defaults. You only keep the keys you want
to change, and the `---@type blak.UserConfig` annotation gives `lua_ls`
completion for Blak config keys.

`user.lua` is gitignored by default so your local setup stays local. Blak also
ships picker ignore metadata so file tools can still find the file.

## Common changes

Switch picker:

```lua
return {
  picker = { provider = "snacks" }, -- fff | snacks | telescope | fzf_lua
}
```

Switch explorer:

```vim
:BlakExtras enable editor.snacks-explorer
```

Or set the provider directly if you are already managing Snacks options:

```lua
return {
  explorer = { provider = "snacks" },
  snacks = { explorer = { enabled = true } },
}
```

Add or override keymaps:

```lua
return {
  keymaps = {
    { key = "<leader>sg", action = "<cmd>BlakPick grep<cr>", description = "Grep" },
    {
      mode = { "n", "x" },
      key = "<leader>y",
      action = '"+y',
      description = "Yank to clipboard",
    },
    {
      key = "<leader>rn",
      action = function()
        vim.lsp.buf.rename()
      end,
      description = "Rename symbol",
    },
    { key = "<leader>/", disable = true },
  },
}
```

Every active mapping needs `description` so it appears in `:BlakKeys`. Use
`mode` for one mode or a list of modes, and use a command string or Lua function
for `action`. Use `disable = true` to remove one of Blak's default mappings
before adding your replacement.

Add Mason tools or Treesitter parsers:

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

Tune LSP diagnostics:

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

## Personal plugins

Use `plugins.specs` for personal lazy.nvim specs that do not belong in Blak
core or a reusable extra:

```lua
return {
  plugins = {
    specs = {
      { "tpope/vim-sleuth", event = "BufReadPost" },
    },
  },
}
```

Blak appends these specs after core and enabled extras, so you can also use
them to tune or disable a default plugin through normal lazy.nvim spec rules.

If the plugin is a broadly useful, reversible feature, consider writing an
[extra](/project/writing-extras/) instead. Extras are the shareable path;
`plugins.specs` is the personal path.

## Lua hooks

Use hooks when a setting is clearer as code than as config:

```lua
return {
  hooks = {
    after = function(config)
      vim.opt.cursorline = false
    end,
  },
}
```

`hooks.before` runs after Blak merges defaults, globals, `user.lua`, and
`setup(opts)`, but before validation and extras apply. Use it to adjust the
merged config before Blak consumes it.

`hooks.after` runs after Blak finishes setup and after each successful
`user.lua` reload. If you create autocmds there, use your own augroup with
`clear = true` so reloads stay clean.

## Full control form

When a table starts fighting you, return a function instead. Blak passes the
config table it is building directly:

```lua
---@param config blak.Config
---@param blak blak.UserContext
return function(config, blak)
  config.picker.provider = "snacks"
  table.insert(config.extras.enabled, "lang.typescript")
  table.insert(config.plugins.specs, { "tpope/vim-sleuth", event = "BufReadPost" })

  config.hooks.after = function()
    vim.opt.cursorline = false
  end
end
```

This is still plain Lua. There is no Blak-specific DSL: `config` starts with
Blak defaults plus `vim.g.blak_config`, then Blak applies any `setup(opts)`,
validates, and applies extras. `blak.util` is available on the second argument
for path, file, notification, and safe-require helpers.

## Merge semantics

Blak deep-merges config tables via `vim.tbl_deep_extend("force", defaults, user)`.

- Scalars in your table replace defaults.
- Tables are merged key by key.
- Lists are replaced by index, so prefer extras or the function form when you
  want to append to defaults.

See the [config schema](/reference/schema/) for valid keys and the
[defaults reference](/reference/defaults/) for what you are overriding.

## When to fork

Fork when you want to change Blak's public contract for everyone: a different
default picker, completion engine, explorer strategy, splash, or upgrade path.
Use `user.lua`, `plugins.specs`, hooks, or an extra when you want to change your
own setup.
