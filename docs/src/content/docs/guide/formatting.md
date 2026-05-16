---
title: Formatting
description: Conform-driven format-on-save with per-buffer and global toggles.
---

Blak uses [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim) for formatting. It runs on `BufWritePre` (when format-on-save is enabled) and via the `:BlakFormat` command and the `<leader>cf` keymap.

Spec: [`lua/blak/plugins/formatting.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/plugins/formatting.lua).

## Defaults

```lua
format = {
  enabled = true,
  timeout_ms = 1000,
  lsp_format = "fallback",
  formatters_by_ft = {
    lua = { "stylua" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
  },
}
```

| Option | Meaning |
| --- | --- |
| `enabled` | Whether format-on-save runs at all. |
| `timeout_ms` | Per-buffer timeout before Conform gives up. |
| `lsp_format` | `"never"`, `"fallback"`, `"prefer"`, or `"first"`. Blak defaults to `"fallback"` — use LSP only when no Conform formatter is configured for the filetype. |
| `formatters_by_ft` | Filetype → ordered formatter list. Each formatter must be installable via Mason (or already on `$PATH`). |

Language extras add to `formatters_by_ft`:

| Extra | Adds |
| --- | --- |
| `lang.typescript` | `prettierd` (fallback `prettier`) for js/ts/jsx/tsx/json |
| `lang.python` | `isort` then `black` for python |
| `lang.markdown` | `prettierd` (fallback `prettier`) for markdown |
| `lang.go` | `goimports`, `gofumpt` for go |
| `lang.rust` | `rustfmt`, `taplo` with `lsp_format = "fallback"` |

## Toggling format-on-save

| Action | How |
| --- | --- |
| Toggle for current buffer | `<leader>uf` or `:BlakFormatToggle` |
| Toggle globally | `:BlakFormatToggle!` (with bang) |
| Format current buffer once | `:BlakFormat` |
| Format inside an LSP-attached buffer | `<leader>cf` |

The flags are simple booleans:

```lua
vim.b.blak_disable_autoformat = true   -- buffer-local
vim.g.blak_disable_autoformat = true   -- global
```

You can flip them in your `user.lua`, an autocmd, or interactively.

## Adding a formatter

Either via `user.lua`:

```lua
return {
  format = {
    formatters_by_ft = {
      yaml = { "prettierd", "prettier" },
      sql  = { "sqlfluff" },
    },
  },
  mason = {
    ensure_installed = { "prettierd", "prettier", "sqlfluff" },
  },
}
```

Or as part of an extra so it's reversible — see [Writing an extra](/project/writing-extras/).

## Customizing a formatter

Conform's `formatters` table lets you override how each tool runs. Use the `apply` hook on an extra, or a direct call in `user.lua`:

```lua
-- in user.lua, after Blak setup
vim.schedule(function()
  require("conform").formatters.shfmt = {
    prepend_args = { "-i", "2", "-ci" },
  }
end)
```

## Skip on save without a flag

If you just want to skip once:

```vim
:noautocmd write
```

Or hold an option key in your terminal's keybinding to a manual write.

## Inspecting

```vim
:lua = require("conform").list_formatters_for_buffer()
:ConformInfo                  " full report on this buffer
```
