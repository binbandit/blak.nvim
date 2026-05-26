---
title: Linting
description: nvim-lint runs standalone linters on every save and edit.
---

Blak uses [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint) to run standalone linters — anything that isn't already an LSP. It fires on the events in `lint.events` (default: `BufWritePost`, `BufReadPost`, `InsertLeave`).

Spec: [`lua/blak/plugins/formatting.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/plugins/formatting.lua) (formatting and linting share a file).

## Defaults

```lua
lint = {
  events = { "BufWritePost", "BufReadPost", "InsertLeave" },
  linters_by_ft = {},
}
```

No linters are configured in core. Linters arrive via [language extras](/guide/extras/#languages):

| Extra | Adds |
| --- | --- |
| `lang.typescript` | `eslint_d` for js/ts/jsx/tsx |
| `lang.typescript-tsgo` | `eslint_d` for js/ts/jsx/tsx |
| `lang.python` | `ruff` for python |
| `lang.go` | `golangcilint` for go |
| `lang.markdown` | `markdownlint` for markdown |

`lang.python-pro` uses Ruff's native LSP diagnostics and code actions instead
of adding a separate nvim-lint entry, so it avoids duplicate Ruff diagnostics.

## Adding a linter

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  lint = {
    linters_by_ft = {
      sh = { "shellcheck" },
      dockerfile = { "hadolint" },
    },
  },
  mason = {
    ensure_installed = { "shellcheck", "hadolint" },
  },
}
```

Or wrap it in an extra so it's reversible.

## Tuning when it runs

```lua
return {
  lint = {
    -- Only on write, not on every InsertLeave or BufReadPost
    events = { "BufWritePost" },
  },
}
```

## Customizing a linter

`nvim-lint` exposes each linter as `require("lint").linters.<name>`. Tweak in `user.lua`:

```lua
vim.schedule(function()
  require("lint").linters.shellcheck.args = {
    "--severity=warning",
    "--shell=bash",
    "-",
  }
end)
```

## Silent on missing tools

If a linter isn't installed (`shellcheck` missing from `$PATH`, say), nvim-lint stays silent — no spam in your messages. The diagnostic just won't appear. Run `:BlakToolsInstall` after adding a Mason-installable linter, or install it yourself.

## Inspecting

```vim
:lua print(vim.inspect(require("lint").linters_by_ft))
:lua require("lint").try_lint()           " trigger now
:lua require("lint").get_running()        " what's running
```
