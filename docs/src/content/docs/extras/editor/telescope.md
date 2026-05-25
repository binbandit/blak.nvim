---
title: Telescope Extra
description: Configure editor.telescope as the Blak picker provider.
---

`editor.telescope` installs Telescope and switches Blak's picker dispatcher to
the Telescope adapter. The `<leader>f*` mappings stay the same; only the picker
backend changes.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "editor.telescope",
    },
  },
}
```

Because this extra adds a plugin, run:

```vim
:BlakExtras sync
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Plugin | `nvim-telescope/telescope.nvim` |
| Dependencies | `plenary.nvim`, `mini.icons` |
| Config | `picker.provider = "telescope"` |
| Prompt | Blak-branded prompt prefix |

## Configure the provider

The extra sets `picker.provider` for you. You can include it explicitly in
`user.lua` if you want the intent visible next to the enabled extra:

```lua
return {
  picker = {
    provider = "telescope",
  },
  extras = {
    enabled = { "editor.telescope" },
  },
}
```

Every `:BlakPick` kind and `<leader>f*` keymap dispatches through the Telescope
adapter when the provider is active.

## Picker coverage

Telescope handles:

| Blak kind | Telescope builtin |
| --- | --- |
| `files` | `find_files` |
| `grep` | `live_grep` |
| `buffers` | `buffers` |
| `recent` | `oldfiles` |
| `commands` | `commands` |
| `keymaps` | `keymaps` |
| `help` | `help_tags` |
| `diagnostics` | `diagnostics` |
| `lsp_symbols` | `lsp_document_symbols` |
| `workspace_symbols` | `lsp_dynamic_workspace_symbols` |

Blak does not expose a Telescope options table in `user.lua`. For deep Telescope
customization, create a local extra with your own Telescope spec.

## Switch back

```lua
return {
  picker = {
    provider = "fff",
  },
  extras = {
    enabled = {},
  },
}
```

Then run `:BlakExtras sync` so lazy.nvim removes Telescope if no other spec uses
it.
