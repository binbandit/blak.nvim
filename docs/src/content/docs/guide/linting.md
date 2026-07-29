---
title: Linting
description: nvim-lint runs standalone linters on every save and edit.
---

Blak uses [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint) to run standalone linters — anything that isn't already an LSP. It fires on the events in `lint.events` (default: `BufWritePost`, `BufReadPost`, `InsertLeave`).

Spec: [`lua/blak/plugins/formatting.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/plugins/formatting.lua) (formatting and linting share a file). The runner itself lives in [`lua/blak/core/linting.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/linting.lua).

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
| `lang.python` | `ruff` for python |
| `lang.go` | `golangcilint` for go |
| `lang.markdown` | `markdownlint` for markdown |
| `lang.bash` | `shellcheck` for sh/bash |
| `lang.docker` | `hadolint` for dockerfile |
| `lang.terraform` | `tflint` for terraform |

`lang.python-pro` uses Ruff's native LSP diagnostics and code actions instead
of adding a separate nvim-lint entry, so it avoids duplicate Ruff diagnostics.
The TypeScript extras do the same with ESLint: they enable the `eslint`
language server rather than running `eslint_d` through nvim-lint. See
[Using eslint_d anyway](#using-eslint_d-anyway) if you want the standalone
daemon back.

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

## Using eslint_d anyway

The TypeScript extras rely on the `eslint` language server, so nothing runs
`eslint_d` by default. To add it back, list it for the filetypes you want and
install it through Mason:

```lua
return {
  extras = {
    enabled = { "lang.typescript" },
  },
  lint = {
    linters_by_ft = {
      javascript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
    },
  },
  mason = {
    ensure_installed = { "eslint_d" },
  },
}
```

Expect ESLint diagnostics from both sources unless you also disable the `eslint`
language server.

## Failure handling

Blak resolves each linter's command before running it. A linter that isn't
installed (`shellcheck` missing from `$PATH`, say) is skipped — no `Error
running shellcheck: ENOENT` on every save, and no diagnostics from that linter.

When a linter does run but writes something Blak can't parse — `eslint_d`
printing a config resolution error to stdout is the common case — the message is
reported once as a warning instead of being attached to line 1 of your buffer as
a fake diagnostic.

To see what's actually wired up and what's missing:

```vim
:checkhealth blak
```

The **Linters** section lists every configured linter and whether its binary was
found. Run `:BlakToolsInstall` after adding a Mason-installable linter, or
install it yourself.

## Inspecting

```vim
:lua print(vim.inspect(require("lint").linters_by_ft))
:lua require("lint").try_lint()           " trigger now
:lua require("lint").get_running()        " what's running
```
