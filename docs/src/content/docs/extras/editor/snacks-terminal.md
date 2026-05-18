---
title: Snacks Terminal Extra
description: Configure editor.snacks-terminal as the Blak terminal provider.
---

`editor.snacks-terminal` switches `:BlakTerminal` from Blak's native terminal
split to `Snacks.terminal.toggle()`. The default toggle key still comes from
`terminal.toggle_key`, so you can keep `<leader>tt` or choose your own mapping.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "editor.snacks-terminal",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable editor.snacks-terminal
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Config | `terminal.provider = "snacks"` |
| Snacks | `terminal.enabled = true` |
| Command | `:BlakTerminal [cmd]` toggles Snacks terminal |
| Keymap | `terminal.toggle_key` toggles Snacks terminal |

The keymap appears in `:BlakKeys`.

## Configure the toggle key

```lua
return {
  extras = {
    enabled = { "editor.snacks-terminal" },
  },
  terminal = {
    toggle_key = "<C-/>",
  },
}
```

Set the key to `false` if you want to keep terminal toggling command-only:

```lua
return {
  extras = {
    enabled = { "editor.snacks-terminal" },
  },
  terminal = {
    toggle_key = false,
  },
}
```

## Configure Snacks terminal

Snacks terminal options go under `snacks.terminal`:

```lua
return {
  extras = {
    enabled = { "editor.snacks-terminal" },
  },
  snacks = {
    terminal = {
      win = {
        position = "bottom",
        height = 0.3,
      },
    },
  },
}
```

## Switch back to native

Remove the extra or disable it:

```vim
:BlakExtras disable editor.snacks-terminal
```

If you set the provider manually, set it back:

```lua
return {
  terminal = {
    provider = "native",
    toggle_key = "<leader>tt",
  },
  extras = {
    enabled = {},
  },
}
```

Restart Blak when you want already-loaded terminal windows and keymaps to
disappear cleanly.
