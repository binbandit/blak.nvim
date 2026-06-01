---
title: Web Extra
description: Configure lang.web for HTML, CSS, Tailwind, and Emmet language servers with Prettier.
---

`lang.web` adds frontend HTML, CSS, Tailwind, and Emmet support with Prettier
formatting. It complements `lang.typescript` rather than replacing it — Tailwind
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
`vscode-langservers-extracted`, `tailwindcss` to `tailwindcss-language-server`,
and `emmet_language_server` to `emmet-language-server`. Only the Prettier
formatters need an explicit Mason entry.

## Notes

- The Tailwind server attaches only when it detects a Tailwind config in the
  project, so there is no cost on non-Tailwind codebases.
- Emmet expansion and Tailwind completion both attach to HTML, CSS, and
  JSX/TSX buffers; they are complementary, not conflicting.

## Install and verify

```vim
:BlakToolsInstall
:BlakTreesitterInstall
:BlakDoctor
```

Open an `.html` or `.css` file and check `:LspInfo` for `html`, `cssls`, and
`emmet_language_server`. Open a file in a Tailwind project to see `tailwindcss`
attach.
