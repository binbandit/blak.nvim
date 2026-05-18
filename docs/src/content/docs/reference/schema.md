---
title: Config schema
description: What's allowed in user.lua and how Blak validates it.
---

Blak validates its merged config on load. Invalid values throw on startup with a clear list of every problem, not the first one. The validation rules live in `lua/blak/config/schema.lua`.

## Top-level keys

All required.

| Key | Type | Notes |
| --- | --- | --- |
| `leader` | `string` | Default `" "` |
| `localleader` | `string` | Default `"\\"` |
| `package` | `table` | See below |
| `ui` | `table` | See below |
| `completion` | `table` | See below |
| `picker` | `table` | See below |
| `explorer` | `table` | See below |
| `terminal` | `table` | See below |
| `keymaps` | `table` | List of user keymap specs |
| `plugins` | `table` | Personal lazy.nvim specs |
| `hooks` | `table` | Lua hooks for pre-validation and post-setup customization |
| `ai` | `table` | See below |
| `mini` | `table` | See below |
| `lsp` | `table` | See below |
| `extras` | `table` | See below |

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
| `key` | `string` | Required key to map |
| `action` | `string`, `function`, or `false` | Required action; `false` disables this key |
| `description` | `string` | Required for active mappings so `:BlakKeys` can show it |
| `disable` | `boolean` | Set `true` to remove this key from Blak |
| `opts` | `table` | Optional `vim.keymap.set()` options |

```lua
return {
  keymaps = {
    { key = "<leader>sg", action = "<cmd>BlakPick grep<cr>", description = "Grep" },
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
      { "folke/trouble.nvim", cmd = "Trouble", opts = {} },
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
| `sidekick` | `table` | Options passed to `folke/sidekick.nvim` when `ai.sidekick` is enabled. Blak sets `nes.enabled = false` by default. |

Use this table for Sidekick CLI and NES configuration:

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

## `mini`

| Key | Type | Notes |
| --- | --- | --- |
| `modules` | `string[]` | Mini module slugs to install and set up when `editor.mini` is enabled. Use `ai`, `surround`, or `mini.ai`; `mini.icons` is already a Blak core plugin. |
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
