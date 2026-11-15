---
title: Tailwind CSS Extra
description: Configure lang.tailwind for Tailwind class completion, hovers, and linting.
---

`lang.tailwind` adds the Tailwind CSS language server on its own, without the
rest of the [`lang.web`](/extras/lang/web/) stack. You get class completion
with color swatches, hover previews of the generated CSS, and `@apply` /
class-conflict diagnostics.

If you already enable `lang.web`, it ships this same Tailwind server config and
you do not need this extra. Enable this one when you want Tailwind without the
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

## Project detection

The server attaches to the nearest directory, searching up from the file, that
has a `tailwind.config.*` file or a `package.json`, `mix.lock`, or
`Gemfile.lock` that depends on Tailwind. Tailwind v4 projects are found through
their `tailwindcss` or `@tailwindcss/*` dependency. Other repositories do not
start the server.

nvim-lspconfig itself falls back to any `.git` root, which starts a server in
every repository; Blak drops that fallback. If your Tailwind setup has none of
these files (for example the standalone CLI), set your own `root_dir`:

```lua
return {
  extras = { enabled = { "lang.tailwind" } },
  lsp = {
    servers = {
      tailwindcss = {
        root_dir = function(bufnr, on_dir)
          local root = vim.fs.root(bufnr, ".git")
          if root then
            on_dir(root)
          end
        end,
      },
    },
  },
}
```

Remove the override to restore Blak's detection.

## Notes

- `classFunctions` needs `tailwindcss-language-server` 0.14 or newer, which is
  what Mason installs.
- Pair it with [`editor.emmet`](/extras/editor/emmet/) for VS Code-style
  `.flex.gap-2` abbreviation expansion.

## Install and verify

```vim
:BlakToolsInstall
:BlakDoctor
```

Open a file in a Tailwind project and check `:checkhealth vim.lsp` for
`tailwindcss`. Typing inside a `class` or `className` attribute should complete
Tailwind classes with color swatches.

## Disable it

Remove `"lang.tailwind"` from `extras.enabled` or run
`:BlakExtras disable lang.tailwind`, then restart Blak.
