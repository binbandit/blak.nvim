---
title: Copilot Extra
description: Configure ai.copilot for the optional GitHub Copilot integration.
---

`ai.copilot` installs `zbirenbaum/copilot.lua` and turns on inline suggestions.
It is never enabled by default, and every mapping it adds is a Blak mapping you
can see in `:BlakKeys`.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "ai.copilot",
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
| Plugin | `zbirenbaum/copilot.lua` |
| Load trigger | `InsertEnter` or `:Copilot` |
| Defaults | `suggestion.enabled = true`, `suggestion.auto_trigger = true`, `panel.enabled = false` |
| Keymaps | `<Space>ag`, `<M-l>`, `<M-w>`, `<M-]>`, `<M-[>`, `<C-]>` |

## Authenticate

Copilot needs Node.js 22 or newer on your `PATH`. After syncing the plugin,
start Neovim and run:

```vim
:Copilot auth
:Copilot status
:checkhealth copilot
```

## Keymaps

| Key | Mode | Action |
| --- | --- | --- |
| `<Space>ag` | Normal | Toggle auto trigger for the current buffer |
| `<M-l>` | Insert | Accept the suggestion |
| `<M-w>` | Insert | Accept one word |
| `<M-]>` | Insert | Next suggestion |
| `<M-[>` | Insert | Previous suggestion |
| `<C-]>` | Insert | Dismiss the suggestion |

`<C-]>` only takes the key when a suggestion is on screen. With no suggestion
it falls through to Neovim's abbreviation expansion.

Copilot ships its own mappings on these keys. Blak disables them and registers
its own so they appear in `:BlakKeys` and can be remapped or removed through
`keymaps` like any other Blak mapping.

## user.lua configuration

`ai.copilot` is passed to `copilot.lua` after Blak's defaults, so you can change
anything except the suggestion keymaps:

```lua
return {
  extras = { enabled = { "ai.copilot" } },
  ai = {
    copilot = {
      -- Copilot skips markdown, yaml, and commit buffers by default.
      filetypes = { markdown = true },
      -- Request suggestions only when you ask with <M-]>.
      suggestion = { auto_trigger = false },
      -- Turn on :Copilot panel.
      panel = { enabled = true },
    },
  },
}
```

Blak leaves the Copilot panel disabled so the extra adds one surface rather than
two, and always disables `copilot.lua`'s built-in keymaps so no mapping is
hidden from `:BlakKeys`.

To install the plugin without any suggestion UI:

```lua
return {
  extras = { enabled = { "ai.copilot" } },
  ai = {
    copilot = {
      suggestion = { enabled = false },
    },
  },
}
```

## Disable it

```vim
:BlakExtras disable ai.copilot
:BlakExtras sync
```

Restart Blak to unload the plugin from the current session.
