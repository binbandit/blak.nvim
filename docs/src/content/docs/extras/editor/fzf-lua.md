---
title: fzf-lua Extra
description: Configure editor.fzf-lua as the Blak picker provider.
---

`editor.fzf-lua` installs fzf-lua and switches Blak's picker dispatcher to the
fzf-lua adapter. The Blak commands and `<leader>f*` mappings stay stable.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "editor.fzf-lua",
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
| Plugin | `ibhagwan/fzf-lua` |
| Dependency | `mini.icons` |
| Config | `picker.provider = "fzf_lua"` |

## Configure the provider

The extra sets the provider for you. Keeping the value in `user.lua` can make
the intended picker obvious:

```lua
return {
  picker = {
    provider = "fzf_lua",
  },
  extras = {
    enabled = { "editor.fzf-lua" },
  },
}
```

## Picker coverage

fzf-lua handles:

| Blak kind | fzf-lua call |
| --- | --- |
| `files` | `files` |
| `grep` | `live_grep` |
| `buffers` | `buffers` |
| `recent` | `oldfiles` |
| `commands` | `commands` |
| `keymaps` | `keymaps` |
| `help` | `help_tags` |
| `diagnostics` | `diagnostics_workspace` |
| `lsp_symbols` | `lsp_document_symbols` |
| `workspace_symbols` | `lsp_workspace_symbols` |

Blak does not expose an fzf-lua options table in `user.lua`. For deep fzf-lua
customization, create a local extra with your own fzf-lua spec.

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

Then run `:BlakExtras sync` so lazy.nvim removes fzf-lua if nothing else uses it.
