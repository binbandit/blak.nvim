---
title: Bash Extra
description: Configure lang.bash for the bash language server with shellcheck diagnostics.
---

`lang.bash` adds the bash language server with shellcheck diagnostics for
shell scripts. Shell formatting with `shfmt` already ships in Blak core, so this
extra layers the language server on top of it.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.bash",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable lang.bash
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `bash` |
| Mason | `shellcheck` |
| LSP | `bashls`, which runs `shellcheck` for `sh` and `bash` |

Formatting for `sh`, `bash`, and `zsh` with `shfmt` is part of Blak core and is
available whether or not this extra is enabled.

## Shellcheck

bashls runs the Mason-installed `shellcheck` as you type, so there is no
separate nvim-lint linter and no duplicate diagnostics. `<leader>ca` on a
warning offers shellcheck's fix or a `# shellcheck disable=` comment. Project
rules belong in `.shellcheckrc`.

To keep bashls but turn shellcheck off:

```lua
return {
  extras = { enabled = { "lang.bash" } },
  lsp = {
    servers = {
      bashls = {
        settings = {
          bashIde = { shellcheckPath = "" },
        },
      },
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

Open a shell script and check `:checkhealth vim.lsp` for `bashls`. Shellcheck
diagnostics appear as soon as the file opens.
