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

Because this extra adds a plugin, run:

```vim
:BlakExtras sync
```

The `markdown` and `markdown_inline` parsers it needs already ship in Blak's
default Treesitter list. If you trimmed that list, also run
`:BlakTreesitterInstall`.

## What it adds

| Surface | Contribution |
| --- | --- |
| Plugin | `MeanderingProgrammer/render-markdown.nvim` |
| Dependencies | `nvim-treesitter`, `mini.icons` |
| Treesitter | `markdown`, `markdown_inline` |
| Setup | `latex = { enabled = false }` |
| Keymap | `<leader>um` toggles Markdown rendering |

The keymap appears in `:BlakKeys`.

## Use it

```vim
:RenderMarkdown toggle
:RenderMarkdown buf_toggle
:RenderMarkdown preview
:checkhealth render-markdown
```

`<leader>um` and `:RenderMarkdown toggle` switch rendering for every Markdown
buffer; `buf_toggle` only affects the current one.

LaTeX rendering is off because it needs the `latex` Treesitter parser and an
external converter (`utftex` or `latex2text`); without them it renders nothing
and only adds `:checkhealth` warnings. To turn it back on once those are
installed, add a matching spec in `plugins.specs`:

```lua
return {
  plugins = {
    specs = {
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { latex = { enabled = true } },
      },
    },
  },
}
```

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
