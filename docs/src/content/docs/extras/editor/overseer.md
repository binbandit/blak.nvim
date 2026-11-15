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
| Keymap | `<leader>oq` picks a task, then an action to run on it |

The keymaps appear in `:BlakKeys`.

## Use it

```vim
:OverseerRun
:OverseerShell make test
:OverseerToggle
:OverseerTaskAction
:checkhealth overseer
```

`:OverseerRun` lists templates Overseer discovers in the project, such as
`make`, `npm`, `cargo`, `just`, and VS Code tasks. `:checkhealth overseer`
reports which template providers are available. Overseer keeps task discovery
and templates in its own configuration. Add a local lazy.nvim spec if you want
project-specific templates.
