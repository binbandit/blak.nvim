---
title: Comfy Line Numbers Extra
description: Configure ui.comfy-line-numbers for left-hand relative line labels.
---

`ui.comfy-line-numbers` enables
[mluders/comfy-line-numbers.nvim](https://github.com/mluders/comfy-line-numbers.nvim).
It shows relative line labels built from left-hand digits and maps those labels
back to normal vertical motions.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "ui.comfy-line-numbers",
    },
  },
}
```

Because this extra adds a plugin, run:

```vim
:BlakExtras sync
```

Or enable it interactively:

```vim
:BlakExtras enable ui.comfy-line-numbers
:BlakExtras sync
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Plugin | `mluders/comfy-line-numbers.nvim` |
| Line numbers | Relative status-column labels using left-hand digits |
| Keymaps | Label + `j` / `k` motions |
| Keymaps | Label + `<Down>` / `<Up>` motions |

Blak registers every label with `j`, `k`, `<Down>`, and `<Up>`, so a label such
as `11` works with both `11j` and `11<Down>`. The plugin also maps the `j`/`k`
labels when it loads; Blak re-applies its described versions afterwards and
removes the plugin's Select-mode copies, so digits typed into a snippet
placeholder stay literal.

The plugin turns on `relativenumber`, since the labels are relative, and adds
`:ComfyLineNumbers enable|disable|toggle` for the current session.

## How the labels work

The displayed label is not the raw relative line count. It is a left-hand digit
label that Blak maps back to the actual count:

| Label | Motion |
| --- | --- |
| `1j` or `1<Down>` | move down 1 line |
| `5k` or `5<Up>` | move up 5 lines |
| `11j` or `11<Down>` | move down 6 lines |
| `34k` or `34<Up>` | move up 19 lines |

The generated mappings work in normal, visual, and operator-pending mode.
They appear in `:BlakKeys` with descriptions. Pressing a label digit and
pausing opens which-key with the matching motions.

## Disable it

Remove `"ui.comfy-line-numbers"` from `extras.enabled` or run:

```vim
:BlakExtras disable ui.comfy-line-numbers
:BlakExtras sync
```

Restart Blak to unload the already-started status-column hooks and generated
motion mappings cleanly.
