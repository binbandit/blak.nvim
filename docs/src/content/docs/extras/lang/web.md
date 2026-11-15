---
title: Web Extra
description: Configure lang.web for HTML, CSS, Tailwind, and Emmet language servers with Prettier.
---

`lang.web` adds frontend HTML, CSS, Tailwind, and Emmet support with Prettier
formatting. It complements `lang.typescript` rather than replacing it. Tailwind
and Emmet also attach to JSX/TSX buffers when they are present.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.web",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable lang.web
```

## What it adds

| Surface | Contribution |
| --- | --- |
| Treesitter | `html`, `css`, `scss` |
| Mason | `prettier`, `prettierd` |
| LSP | `html`, `cssls`, `tailwindcss`, `emmet_language_server` |
| Formatting | `prettierd` (fallback `prettier`) for `html`, `css`, `scss`, `less` |

Language servers install automatically through Mason: `html`/`cssls` map to
`html-lsp` and `css-lsp`, `tailwindcss` to `tailwindcss-language-server`,
and `emmet_language_server` to `emmet-language-server`. Only the Prettier
formatters need an explicit Mason entry.

## Notes

- The Tailwind server uses the same project detection as
  [`lang.tailwind`](/extras/lang/tailwind/#project-detection): it attaches only
  inside a Tailwind project, so non-Tailwind repositories do not start it.
- Emmet expansion and Tailwind completion both attach to HTML, CSS, and
  JSX/TSX buffers; they are complementary, not conflicting.
- Want just one piece? [`lang.tailwind`](/extras/lang/tailwind/) and
  [`editor.emmet`](/extras/editor/emmet/) ship the Tailwind and Emmet servers
  standalone.

## Tailwind directives in CSS

`cssls` does not know Tailwind at-rules, so in a Tailwind project it warns
`Unknown at rule @apply` (or `@theme`, `@tailwind`). The `tailwindcss` server
already checks those rules. To silence the duplicate warning, ignore unknown
at-rules in `user.lua`:

```lua
return {
  extras = { enabled = { "lang.web" } },
  lsp = {
    servers = {
      cssls = {
        settings = {
          css = { lint = { unknownAtRules = "ignore" } },
          scss = { lint = { unknownAtRules = "ignore" } },
          less = { lint = { unknownAtRules = "ignore" } },
        },
      },
    },
  },
}
```

This applies to every project, so `cssls` also stops flagging misspelled
at-rules elsewhere. Remove the entry to restore the warning.

## Install and verify

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open an `.html` or `.css` file and check `:checkhealth vim.lsp` for `html`,
`cssls`, and `emmet_language_server`. Open a file in a Tailwind project to see
`tailwindcss` attach.
