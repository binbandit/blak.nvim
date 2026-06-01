---
title: Bash Extra
description: Configure lang.bash for the bash language server and shellcheck linting.
---

`lang.bash` adds the bash language server and shellcheck linting for shell
scripts. Shell formatting with `shfmt` already ships in Blak core, so this
extra layers the language server and linter on top of it.

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
| LSP | `bashls` |
| Linting | `shellcheck` for `sh`, `bash` |

Formatting for `sh`, `bash`, and `zsh` with `shfmt` is part of Blak core and is
available whether or not this extra is enabled.

## Configure linting

The extra maps shell files to nvim-lint's `shellcheck`. Disable it with an
empty list when a project relies only on the language server:

```lua
return {
  extras = { enabled = { "lang.bash" } },
  lint = {
    linters_by_ft = {
      sh = {},
      bash = {},
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

Open a shell script and check `:LspInfo` for `bashls`. Save the file to see
`shellcheck` diagnostics.
