---
title: Tailwind CSS Extra
description: Configure lang.tailwind for Tailwind class completion, hovers, and linting.
---

`lang.tailwind` adds the Tailwind CSS language server on its own, without the
rest of the [`lang.web`](/extras/lang/web/) stack. You get class completion
with color swatches, hover previews of the generated CSS, and `@apply` /
class-conflict diagnostics.

If you already enable `lang.web`, the Tailwind server is included there and you
do not need this extra — enable this one when you want Tailwind without the
HTML, CSS, Emmet, and Prettier pieces.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "lang.tailwind",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable lang.tailwind
```

## What it adds

| Surface | Contribution |
| --- | --- |
| LSP | `tailwindcss` (installs as `tailwindcss-language-server` through Mason) |

The server config ships two quality-of-life settings:

- `classAttributes` covers `class`, `className`, `class:list`, `classList`,
  and `ngClass`, so completion works in React, Astro, Solid, and Angular
  attribute styles.
- `classFunctions` covers `clsx`, `cn`, `cva`, `cx`, `tw`, and `twMerge`, so
  completion and lint also work inside those call sites.

Override either through `lsp.servers.tailwindcss` in `user.lua`:

```lua
return {
  extras = { enabled = { "lang.tailwind" } },
  lsp = {
    servers = {
      tailwindcss = {
        settings = {
          tailwindCSS = {
            classFunctions = { "tv" },
          },
        },
      },
    },
  },
}
```

## Notes

- The server attaches only when it detects a Tailwind config in the project,
  so there is no cost on non-Tailwind codebases.
- `classFunctions` needs `tailwindcss-language-server` 0.14 or newer, which is
  what Mason installs.
- Pair it with [`editor.emmet`](/extras/editor/emmet/) for VS Code-style
  `.flex.gap-2` abbreviation expansion.

## Install and verify

```vim
:BlakToolsInstall
:BlakDoctor
```

Open a file in a Tailwind project and check `:LspInfo` for `tailwindcss`.
Typing inside a `class` or `className` attribute should complete Tailwind
classes with color swatches.

## Disable it

Remove `"lang.tailwind"` from `extras.enabled` or run
`:BlakExtras disable lang.tailwind`, then restart Blak.
