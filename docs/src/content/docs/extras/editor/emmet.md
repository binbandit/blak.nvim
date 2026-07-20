---
title: Emmet Extra
description: Configure editor.emmet for VS Code-style Emmet abbreviation expansion.
---

`editor.emmet` adds Emmet abbreviation expansion the way VS Code ships it:
type an abbreviation, and the completion menu offers the expanded markup. Type
`.block` in a JSX buffer, accept the suggestion, and you get
`<div className="block"></div>`. In HTML the same abbreviation expands to
`<div class="block"></div>`.

If you already enable [`lang.web`](/extras/lang/web/), the Emmet server is
included there and you do not need this extra — enable this one when you want
Emmet without the rest of the web stack.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "editor.emmet",
    },
  },
}
```

Or enable it interactively:

```vim
:BlakExtras enable editor.emmet
```

## What it adds

| Surface | Contribution |
| --- | --- |
| LSP | `emmet_language_server` (installs as `emmet-language-server` through Mason) |

The extra pins the attach list so it stays inspectable: `html`, `css`, `scss`,
`less`, `sass`, `javascriptreact`, `typescriptreact`, `vue`, `svelte`, and
`astro`. Plain `javascript` and `typescript` are deliberately left out so
Emmet suggestions do not pollute completion in non-markup code. Add filetypes
through `lsp.servers` in `user.lua`:

```lua
return {
  extras = { enabled = { "editor.emmet" } },
  lsp = {
    servers = {
      emmet_language_server = {
        filetypes = { "html", "javascriptreact", "typescriptreact", "eruby" },
      },
    },
  },
}
```

## How expansion works

Emmet integrates through completion, not a separate keymap:

1. Type an abbreviation: `.block`, `ul>li*3`, `section#hero.dark`.
2. The completion menu shows the expanded markup as a snippet suggestion.
3. Accept it and the cursor lands inside the generated element.

JSX and TSX buffers expand with `className`, matching VS Code's built-in
Emmet.

## Install and verify

```vim
:BlakToolsInstall
:BlakDoctor
```

Open an `.html` or `.tsx` file, check `:LspInfo` for `emmet_language_server`,
type `.block`, and accept the completion.

## Disable it

Remove `"editor.emmet"` from `extras.enabled` or run
`:BlakExtras disable editor.emmet`, then restart Blak.
