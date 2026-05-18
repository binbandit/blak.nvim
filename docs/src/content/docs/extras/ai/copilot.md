---
title: Copilot Extra
description: Configure ai.copilot for the optional GitHub Copilot integration.
---

`ai.copilot` installs `zbirenbaum/copilot.lua`. It is never enabled by default,
and Blak does not add AI keymaps or silently change completion behavior.

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
| Defaults | `suggestion.enabled = false`, `panel.enabled = false` |

## Authenticate

After syncing the plugin, start Neovim and run:

```vim
:Copilot auth
:Copilot status
```

## user.lua configuration

The public Blak config for this extra is the opt-in itself:

```lua
return {
  extras = {
    enabled = { "ai.copilot" },
  },
}
```

Blak intentionally leaves inline suggestions and the Copilot panel disabled in
the extra's default spec. That prevents the AI integration from taking over
insert-mode behavior or adding hidden mappings.

If you want a different Copilot UI, create a local extra with your own
`copilot.lua` options so the behavior remains explicit and easy to remove.

## Disable it

```vim
:BlakExtras disable ai.copilot
:BlakExtras sync
```

Restart Blak to unload the plugin from the current session.
