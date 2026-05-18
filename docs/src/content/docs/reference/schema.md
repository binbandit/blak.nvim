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
| `picker` | `table` | See below |
| `explorer` | `table` | See below |
| `terminal` | `table` | See below |
| `ai` | `table` | See below |
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

## `picker`

| Key | Type | Allowed |
| --- | --- | --- |
| `provider` | `string` | `"fff"`, `"snacks"`, `"telescope"`, or `"fzf_lua"` |

Switching providers swaps the implementation behind `:BlakPick` without changing the keymaps. If you want a provider that doesn't exist yet, add it under `lua/blak/providers/picker.lua` and submit a PR.

## `explorer`

| Key | Type | Allowed |
| --- | --- | --- |
| `provider` | `string` | `"oil"` or `"snacks"` |

Switching providers swaps the implementation behind `<leader>e` and directory-buffer takeover. The usual path is `:BlakExtras enable editor.snacks-explorer`, which sets this option and enables the Snacks explorer module for you.

## `terminal`

| Key | Type | Allowed |
| --- | --- | --- |
| `provider` | `string` | `"native"` or `"snacks"` |
| `toggle_key` | `string` or `false` | Any key lhs accepted by `vim.keymap.set()`, or `false` to skip the keymap |

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

## `extras`

| Key | Type | Notes |
| --- | --- | --- |
| `enabled` | `string[]` | List of extra IDs. Validation only checks that entries are strings — unknown IDs surface as a warning at runtime, not a hard error. |

The runtime warning gives you a chance to keep using your config after renaming an extra in the repo.

## Deep merge semantics

`user.lua` returns a table that is **deep-merged** into the defaults via `vim.tbl_deep_extend("force", defaults, user)`:

- Scalars in your table replace defaults.
- Tables are merged key by key.
- **Lists are replaced wholesale.** If you write `treesitter = { ensure_installed = { "rust" } }`, you lose the entire default list.

To extend the default list instead, copy it from [the defaults page](/reference/defaults/) and add your entries — or use an extra, which is designed exactly for this use case.

## Error handling

If validation fails on startup, `require("blak").setup()` raises and Blak does not load. You'll see the original Neovim banner and the error message in `:messages`.

If validation or evaluation fails during an automatic `user.lua` reload, Blak warns and keeps the previous in-session config active. Fix `user.lua` and save it again.

The error message is verbose on purpose:

```text
Blak config validation failed:
- package.channel must be stable, edge, or nightly
- picker.provider must be fff, snacks, telescope, or fzf_lua
- explorer.provider must be oil or snacks
- terminal.provider must be native or snacks
- extras.enabled entries must be strings
```

Multiple problems are reported in one pass so you don't fix one and immediately hit the next.
