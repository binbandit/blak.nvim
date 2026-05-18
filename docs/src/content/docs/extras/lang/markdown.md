---
title: Markdown Extra
description: Configure lang.markdown for Marksman, Prettier, markdownlint, and Markdown Treesitter support.
---

`lang.markdown` adds editing support for prose-heavy repositories, docs sites,
and README work.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.markdown",
    },
  },
}
```

Or enable it with:

```vim
:BlakExtras enable lang.markdown
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `markdown`, `markdown_inline` |
| Mason | `prettier`, `prettierd`, `markdownlint` |
| LSP | `marksman` |
| Formatting | `prettierd`, falling back to `prettier`, for `markdown` |
| Linting | `markdownlint` for `markdown` |

## Configure Marksman

Marksman is registered as `marksman`. Add server options there if needed:

```lua
return {
  extras = {
    enabled = { "lang.markdown" },
  },
  lsp = {
    servers = {
      marksman = {
        filetypes = { "markdown" },
      },
    },
  },
}
```

## Configure formatting

The default uses `prettierd` first and falls back to `prettier`:

```lua
return {
  extras = {
    enabled = { "lang.markdown" },
  },
  format = {
    formatters_by_ft = {
      markdown = { "prettierd", "prettier", stop_after_first = true },
    },
  },
}
```

To use only the plain Prettier binary:

```lua
return {
  extras = {
    enabled = { "lang.markdown" },
  },
  format = {
    formatters_by_ft = {
      markdown = { "prettier" },
    },
  },
}
```

## Configure linting

The extra maps Markdown files to `markdownlint`. Keep rules in project config
such as `.markdownlint.json`, or disable the editor lint hook:

```lua
return {
  extras = {
    enabled = { "lang.markdown" },
  },
  lint = {
    linters_by_ft = {
      markdown = {},
    },
  },
}
```

## Install and verify

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open a Markdown file and check `:LspInfo` for `marksman`.
