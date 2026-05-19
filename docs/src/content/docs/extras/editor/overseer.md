---
title: Overseer Extra
description: Configure editor.overseer as an opt-in task runner.
---

`editor.overseer` installs [overseer.nvim](https://github.com/stevearc/overseer.nvim),
a task runner for project commands such as `make`, `npm`, `cargo`, and VS Code
task definitions.

## Enable it

```lua
return {
  extras = {
    enabled = {
      "editor.overseer",
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
| Plugin | `stevearc/overseer.nvim` |
| Keymap | `<leader>oo` toggles the task list |
| Keymap | `<leader>or` runs a task |
| Keymap | `<leader>oq` opens task quick actions |

The keymaps appear in `:BlakKeys`.

## Use it

```vim
:OverseerRun
:OverseerToggle
:OverseerQuickAction
```

Overseer keeps task discovery and templates in its own configuration. Add a
local lazy.nvim spec if you want project-specific templates.
