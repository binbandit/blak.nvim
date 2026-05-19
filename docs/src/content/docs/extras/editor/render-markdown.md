---
title: Render Markdown Extra
description: Configure editor.render-markdown for in-buffer Markdown rendering.
---

`editor.render-markdown` installs
[render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)
for richer in-buffer Markdown rendering. It changes how Markdown buffers look,
so it stays separate from `lang.markdown`.

## Enable it

```lua
return {
  extras = {
    enabled = {
      "editor.render-markdown",
    },
  },
}
```

Because this extra adds a plugin and Treesitter parsers, run:

```vim
:BlakExtras sync
:BlakTreesitterInstall
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Plugin | `MeanderingProgrammer/render-markdown.nvim` |
| Dependencies | `nvim-treesitter`, `mini.icons` |
| Treesitter | `markdown`, `markdown_inline` |
| Keymap | `<leader>um` toggles Markdown rendering |

The keymap appears in `:BlakKeys`.

## Pair it with Markdown language support

Enable both extras when you want LSP, formatting, linting, and rendering:

```lua
return {
  extras = {
    enabled = {
      "lang.markdown",
      "editor.render-markdown",
    },
  },
}
```
