---
title: Config schema
description: What's allowed in user.lua and how Blak validates it.
---

Blak validates its merged config on load. Invalid values throw on startup with a clear list of every problem, not the first one. The validation rules live in `lua/blak/config/schema.lua`.

## Top-level keys

All present after merging with the defaults. Keys marked *validated* are
checked by `schema.lua` on load; the rest are deep-merged and passed to the
modules that consume them without per-field validation.

| Key | Type | Notes |
| --- | --- | --- |
| `version` | `string` | Blak's own version string. Informational; do not set it in `user.lua` |
| `leader` | `string` | Default `" "`. Validated |
| `localleader` | `string` | Default `"\\"`. Validated |
| `package` | `table` | See below. Validated |
| `ui` | `table` | See below. Validated |
| `editor` | `table` | See below. Validated |
| `completion` | `table` | See below. Validated |
| `performance` | `table` | See below |
| `picker` | `table` | See below. Validated |
| `explorer` | `table` | See below. Validated |
| `terminal` | `table` | See below. Validated |
| `keymaps` | `table` | List of user keymap specs. Validated |
| `plugins` | `table` | Personal lazy.nvim specs. Validated |
| `hooks` | `table` | Lua hooks for pre-validation and post-setup customization. Validated |
| `ai` | `table` | See below. Validated |
| `mini` | `table` | See below. Validated |
| `snacks` | `table` | See below |
| `treesitter` | `table` | See below |
| `lsp` | `table` | See below |
| `mason` | `table` | See below |
| `format` | `table` | See below |
| `lint` | `table` | See below |
| `extras` | `table` | See below. Validated |

## `package`

| Key | Type | Allowed |
| --- | --- | --- |
| `backend` | `string` | `"lazy"` |
| `channel` | `string` | `"stable"`, `"edge"`, or `"nightly"` |
| `check_updates` | `boolean` | — |

Setting an unsupported `channel` raises:

```text
Blak config validation failed:
- package.channel must be stable, edge, or nightly
```

## `ui`

| Key | Type | Allowed |
| --- | --- | --- |
| `colorscheme` | `string` | Any installed colorscheme name |
| `transparent` | `boolean` | `true` or `false` |
| `theme` | `table` | Options passed to a colorscheme Lua `setup()` function when available |

Set `ui.transparent = true` to clear editor background highlights after the
active colorscheme loads. Use `ui.theme` for colorscheme-native setup options.
Blak tries the colorscheme name first, then the name before the final dash.
Configure custom themes with unusual setup rules through `plugins.specs`.

## `editor`

| Key | Type | Notes |
| --- | --- | --- |
| `clipboard` | `boolean` | Use the system clipboard when available |
| `confirm` | `boolean` | Prompt before commands abandon unsaved changes |
| `relative_number` | `boolean` | Toggle relative line numbers |
| `scrolloff` | `number` | Context lines above and below the cursor |
| `sidescrolloff` | `number` | Context columns beside the cursor |
| `tabstop` | `number` | Width used to display a tab character |
| `shiftwidth` | `number` | Indent width for operators and new lines |
| `expandtab` | `boolean` | Insert spaces instead of tab characters |

Disable confirm prompts in `user.lua`:

```lua
return {
  editor = {
    confirm = false,
  },
}
```

## `picker`

| Key | Type | Allowed |
| --- | --- | --- |
| `provider` | `string` | `"fff"`, `"snacks"`, `"telescope"`, or `"fzf_lua"` |

Switching providers swaps the implementation behind `:BlakPick` without changing the keymaps. If you want a provider that doesn't exist yet, add it under `lua/blak/providers/picker.lua` and submit a PR.

## `completion`

| Key | Type | Allowed |
| --- | --- | --- |
| `super_tab` | `boolean` | `true` or `false` |

Set `completion.super_tab = true` to use the completion engine's SuperTab-style
keymap preset where Blak can delegate to one. The default is `false`, so stable
updates do not change completion muscle memory.

## `explorer`

| Key | Type | Allowed |
| --- | --- | --- |
| `provider` | `string` | `"oil"` or `"snacks"` |

Switching providers swaps the implementation behind `<leader>e` and directory-buffer takeover. The usual path is `:BlakExtras enable editor.snacks-explorer`, which sets this option and enables the Snacks explorer module for you.

## `terminal`

| Key | Type | Allowed |
| --- | --- | --- |
| `provider` | `string` | `"native"` or `"snacks"` |
| `toggle_key` | `string` or `false` | Any key accepted by `vim.keymap.set()`, or `false` to skip the keymap |

The usual path for Snacks terminal is `:BlakExtras enable editor.snacks-terminal`,
which sets `terminal.provider = "snacks"` and enables the Snacks terminal module
for you. Set `terminal.toggle_key` when you want a different toggle mapping:

```lua
return {
  extras = { enabled = { "editor.snacks-terminal" } },
  terminal = {
    toggle_key = "<C-/>",
  },
}
```

## `keymaps`

`keymaps` is a list of user mappings applied after core and enabled extras.

| Key | Type | Notes |
| --- | --- | --- |
| `mode` | `string` or `string[]` | Optional; defaults to `"n"` |
| `modes` | `string` or `string[]` | Alias for `mode`; use one or the other |
| `key` | `string` | Required key to map |
| `action` | `string`, `function`, or `false` | Required action; `false` disables this key |
| `description` | `string` | Required for active mappings so `:BlakKeys` can show it |
| `disable` | `boolean` | Set `true` to remove this key from Blak |
| `opts` | `table` | Optional `vim.keymap.set()` options |

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

To move a default action, disable the old key and add the new one.
This keeps user muscle memory explicit without hiding mappings from
`:BlakKeys`.

Blak still accepts `lhs`, `rhs`, and `desc` as aliases for users already
familiar with Vim terminology, but the documented `user.lua` shape uses the
more direct names above.

## `plugins`

| Key | Type | Notes |
| --- | --- | --- |
| `specs` | `table` | List of lazy.nvim specs appended after Blak core and enabled extras |

```lua
return {
  plugins = {
    specs = {
      { "tpope/vim-sleuth", event = "BufReadPost" },
    },
  },
}
```

Use this for personal plugins. If the behavior is broadly useful and
reversible, prefer a documented extra so other users can enable and disable it
through `:BlakExtras`.

## `hooks`

| Key | Type | Notes |
| --- | --- | --- |
| `before` | `function` or `function[]` | Runs after merge, before validation and extras |
| `after` | `function` or `function[]` | Runs after startup and after successful `user.lua` reloads |

```lua
return {
  hooks = {
    after = function(config)
      vim.opt.cursorline = false
    end,
  },
}
```

Hooks receive `(config, blak)`. `config` is the merged Blak config table, and
`blak.util` is available on the second argument.

## `ai`

| Key | Type | Notes |
| --- | --- | --- |
| `claudecode` | `table` | Options passed to `coder/claudecode.nvim` when `ai.claudecode` is enabled. Blak sets `terminal.provider = "snacks"` by default. |
| `sidekick` | `table` | Options passed to `folke/sidekick.nvim` when `ai.sidekick` is enabled. Blak sets `nes.enabled = false` by default. |
| `supermaven` | `table` | Options passed to `supermaven-inc/supermaven-nvim` when `ai.supermaven` is enabled. Blak always disables the plugin's built-in keymaps. |

Use this table for Claude Code configuration:

```lua
return {
  extras = { enabled = { "ai.claudecode" } },
  ai = {
    claudecode = {
      terminal = {
        provider = "snacks",
      },
      diff_opts = {
        layout = "vertical",
      },
    },
  },
}
```

Use `ai.sidekick` for Sidekick CLI and NES configuration:

```lua
return {
  extras = { enabled = { "ai.sidekick" } },
  ai = {
    sidekick = {
      nes = { enabled = true },
      cli = {
        mux = { enabled = true, backend = "tmux" },
      },
    },
  },
}
```

Use `ai.supermaven` to tune Supermaven without enabling its hidden keymaps:

```lua
return {
  extras = { enabled = { "ai.supermaven" } },
  ai = {
    supermaven = {
      ignore_filetypes = { markdown = true },
      log_level = "info",
    },
  },
}
```

## `mini`

| Key | Type | Notes |
| --- | --- | --- |
| `modules` | `string[]` | Mini module slugs to install and set up when `editor.mini` is enabled. Use `ai`, `surround`, or `mini.ai`; `mini.icons` and pair handling already ship in core. |
| `opts` | `table<string, table>` | Per-module options passed to `require("mini.<module>").setup()` |

The Mini extra is intentionally inert until you choose modules:

```lua
return {
  extras = { enabled = { "editor.mini" } },
  mini = {
    modules = { "ai", "surround", "pairs" },
    opts = {
      surround = { n_lines = 80 },
    },
  },
}
```

## `performance`

| Key | Type | Notes |
| --- | --- | --- |
| `bigfile_size` | `number` | Size in bytes above which Snacks bigfile mode trims heavy features. Default 1.5 MiB |
| `max_treesitter_lines` | `number` | Buffers with more lines than this skip Treesitter highlighting. Default `10000` |

## `snacks`

A table deep-merged over Blak's own `snacks.nvim` options, last-write-wins.
Use it to tune or disable individual Snacks modules:

```lua
return {
  snacks = {
    words = { enabled = false },
  },
}
```

The full option surface is the upstream `snacks.nvim` config; Blak validates
only that the value is mergeable.

## `treesitter`

| Key | Type | Notes |
| --- | --- | --- |
| `ensure_installed` | `string[]` | Parsers installed at startup |

Per the deep merge semantics below, setting `ensure_installed` in the simple
table form **replaces** the default parser list. Use the function form or an
extra to append.

## `lsp`

| Key | Type | Notes |
| --- | --- | --- |
| `automatic_enable` | `boolean` | Enable configured servers automatically through `vim.lsp.enable()` |
| `servers` | `table<string, table>` | Per-server options passed to `vim.lsp.config()` |
| `diagnostics` | `table` | Passed to `vim.diagnostic.config()` |

```lua
return {
  lsp = {
    servers = {
      gopls = {},
    },
    diagnostics = {
      virtual_text = false,
    },
  },
}
```

Language extras add their servers to `lsp.servers` for you; use this table
directly when you want a server without the rest of an extra. Validation only
checks that `lsp` is a table.

## `mason`

| Key | Type | Notes |
| --- | --- | --- |
| `automatic_install` | `boolean` | Install `ensure_installed` tools through Mason on startup |
| `ensure_installed` | `string[]` | Mason package names |

## `format`

| Key | Type | Notes |
| --- | --- | --- |
| `enabled` | `boolean` | Format on save. `vim.g.blak_disable_autoformat` and `vim.b.blak_disable_autoformat` override per session or buffer |
| `timeout_ms` | `number` | Formatter timeout per save |
| `lsp_format` | `string` | Conform's `lsp_format` mode; default `"fallback"` |
| `formatters_by_ft` | `table<string, string[]>` | Conform formatters per filetype |

## `lint`

| Key | Type | Notes |
| --- | --- | --- |
| `events` | `string[]` | Autocmd events that trigger nvim-lint; empty list disables event-driven linting |
| `linters_by_ft` | `table<string, string[]>` | nvim-lint linters per filetype |

## `extras`

| Key | Type | Notes |
| --- | --- | --- |
| `enabled` | `blak.ExtraId[]` | List of extra IDs. `lua_ls` completes known IDs like `lang.typescript`, `editor.mini`, and `git.lazygit`. Validation only checks that entries are strings — unknown IDs surface as a warning at runtime, not a hard error. |

The runtime warning gives you a chance to keep using your config after renaming an extra in the repo.

## Deep merge semantics

The simple `user.lua` form returns a table that is **deep-merged** into the
defaults via `vim.tbl_deep_extend("force", defaults, user)`:

- Scalars in your table replace defaults.
- Tables are merged key by key.
- **Lists are replaced wholesale.** If you write `treesitter = { ensure_installed = { "rust" } }`, you lose the entire default list.

To append to default lists, use an extra or return a function:

```lua
return function(config)
  table.insert(config.treesitter.ensure_installed, "rust")
end
```

The function form receives the config table Blak is building. Mutate it in
place and return nothing, or return a table of final overrides.

## Error handling

If validation fails on startup, `require("blak").setup()` raises and Blak does not load. You'll see the original Neovim banner and the error message in `:messages`.

If validation or evaluation fails during an automatic `user.lua` reload, Blak warns and keeps the previous in-session config active. Fix `user.lua` and save it again.

The error message is verbose on purpose:

```text
Blak config validation failed:
- package.channel must be stable, edge, or nightly
- picker.provider must be fff, snacks, telescope, or fzf_lua
- completion.super_tab must be boolean, got string
- explorer.provider must be oil or snacks
- terminal.provider must be native or snacks
- extras.enabled entries must be strings
```

Multiple problems are reported in one pass so you don't fix one and immediately hit the next.
