---
title: Pickers
description: One picker entrypoint, four interchangeable backends.
---

`:BlakPick` and the `<leader>f*` keymaps dispatch through a provider adapter, not a specific picker plugin. That means **you can swap your picker backend without re-learning a single keymap**.

The provider lives in [`lua/blak/providers/picker/`](https://github.com/binbandit/blak.nvim/tree/main/lua/blak/providers/picker).

## Available providers

| Provider | Plugin | When to use |
| --- | --- | --- |
| `fff` (default) | [dmtrKovalenko/fff](https://github.com/dmtrKovalenko/fff) | Snappiest on the common path. Native binary backend. |
| `snacks` | [folke/snacks.nvim](https://github.com/folke/snacks.nvim) picker | Already loaded for the dashboard, so zero extra deps. |
| `telescope` | [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Familiar, extensible. Enabled via `editor.telescope` extra. |
| `fzf_lua` | [ibhagwan/fzf-lua](https://github.com/ibhagwan/fzf-lua) | Fastest fuzzy match if you've already got fzf. Enabled via `editor.fzf-lua` extra. |

## Switching provider

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  picker = { provider = "snacks" },  -- fff | snacks | telescope | fzf_lua
}
```

Or enable a provider-loading extra:

```vim
:BlakExtras enable editor.telescope   " sets provider = telescope and loads the plugin
:BlakExtras enable editor.fzf-lua     " sets provider = fzf_lua and loads the plugin
```

Run `:BlakExtras sync` if the plugin is not installed yet. Every `<leader>f*` mapping uses the new backend as soon as the provider is available.

## Fallback chain

If the configured provider isn't loadable, the dispatcher falls back: **configured → snacks → fff → telescope → fzf_lua**. This is why a fresh install never lacks a working picker, even before extras are enabled or Mason has finished installing tools.

A provider that supports the requested kind but fails at call time is not skipped silently: Blak warns with the provider name and the error before trying the next one, so a broken picker configuration stays visible instead of being papered over.

Source: [`lua/blak/providers/picker/init.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/providers/picker/init.lua).

## Picker kinds

`:BlakPick {kind}` and the keymaps map to these provider methods:

| Kind | fff | snacks | telescope | fzf_lua |
| --- | --- | --- | --- | --- |
| `files` | ✓ | ✓ | `find_files` | `files` |
| `grep` | ✓ | live_grep | `live_grep` | `live_grep` |
| `buffers` | — | ✓ | `buffers` | `buffers` |
| `recent` | — | recent | `oldfiles` | `oldfiles` |
| `commands` | — | ✓ | `commands` | `commands` |
| `keymaps` | — | ✓ | `keymaps` | `keymaps` |
| `help` | — | ✓ | `help_tags` | `help_tags` |
| `diagnostics` | — | ✓ | `diagnostics` | `diagnostics_workspace` |
| `lsp_symbols` | — | ✓ | `lsp_document_symbols` | `lsp_document_symbols` |
| `workspace_symbols` | — | ✓ | `lsp_dynamic_workspace_symbols` | `lsp_workspace_symbols` |

When a method is missing on the configured provider, the dispatcher falls back to one that has it.
The old `smart` kind is accepted as an alias for `files`.

## Writing a new provider

Drop a file at `lua/blak/providers/picker/<name>.lua` that returns a table of method-named functions:

```lua
local M = {}

function M.files(opts) ... end
function M.grep(opts) ... end
-- ...

return M
```

Then register it in [`lua/blak/providers/picker/init.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/providers/picker/init.lua) and add it to the schema's allowed values in [`lua/blak/config/schema.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/config/schema.lua).

PRs welcome.
