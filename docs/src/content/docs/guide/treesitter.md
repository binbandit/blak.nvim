---
title: Treesitter
description: Parser installation, performance gating, and the main-branch API.
---

Blak uses the `main` branch of nvim-treesitter — the new API that ships parsers as part of `nvim-treesitter` itself rather than requiring per-parser modules.

Setup: [`lua/blak/core/treesitter.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/treesitter.lua). Spec: [`lua/blak/plugins/editor.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/plugins/editor.lua).

## Default parsers

```lua
treesitter = {
  ensure_installed = {
    "bash", "c", "diff", "html", "json", "lua", "luadoc",
    "markdown", "markdown_inline", "query", "regex", "toml",
    "vim", "vimdoc", "yaml",
  },
}
```

Language extras add to this list automatically:

| Extra | Adds |
| --- | --- |
| `lang.typescript` | `javascript`, `typescript`, `tsx`, `jsdoc`, `json` |
| `lang.typescript-tsgo` | `javascript`, `typescript`, `tsx`, `jsdoc`, `json` |
| `lang.python` | `python` |
| `lang.python-pro` | `python`, `requirements` |
| `lang.rust` | `rust`, `toml` |
| `lang.go` | `go`, `gomod`, `gosum`, `gowork` |
| `lang.markdown` | `markdown`, `markdown_inline` |

`.jsonc` files reuse the `json` parser — nvim-treesitter no longer ships a
separate `jsonc` grammar — so JSONC highlighting works without its own parser.

## Installing parsers

```vim
:BlakTreesitterInstall
```

Calls `nvim-treesitter.install()` with your merged list and notifies on completion. The compile step needs `tree-sitter` on `$PATH` — Blak ships `tree-sitter-cli` in the default Mason set, so on a first launch `:BlakToolsInstall` followed by `:BlakTreesitterInstall` is enough.

You can also install one parser at a time:

```vim
:lua require("nvim-treesitter").install({ "zig" })
```

## Per-buffer activation

Treesitter only starts on a buffer when:

1. Its `filetype` has an installed parser.
2. Its line count is below `performance.max_treesitter_lines` (default `10000`).

The check happens on `FileType`:

```lua
-- lua/blak/core/treesitter.lua, abbreviated
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    if vim.api.nvim_buf_line_count(args.buf) > max_lines then return end
    pcall(vim.treesitter.start, args.buf)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
```

So opening a 200k-line log file won't grind to a halt — treesitter just doesn't attach.

## Tuning the line cap

```lua
return {
  performance = {
    max_treesitter_lines = 25000,
  },
}
```

## Adding a parser permanently

Either in `user.lua`:

```lua
return {
  treesitter = {
    ensure_installed = { "bash", "lua", "zig", "yaml" },
  },
}
```

> **Lists are replaced wholesale** — write out everything you want, or add it via an extra so the merge is additive.

Or as an extra:

```lua
-- lua/blak/extras/lang/zig.lua
return {
  id = "lang.zig",
  label = "Zig",
  treesitter = { "zig" },
  mason = { "zls" },
  lsp = { servers = { zls = {} } },
}
```

## Indent

Blak sets `indentexpr` to nvim-treesitter's indent function on every buffer that gets a parser. If you want a language-specific indent, override via filetype autocmd in `user.lua`.

## Inspecting

```vim
:checkhealth nvim-treesitter         " native checker
:Inspect                             " show the tree at cursor
:InspectTree                         " open the parse tree
```
