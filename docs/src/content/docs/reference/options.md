---
title: Editor options
description: Every vim.opt Blak sets, what it does, and how to override.
---

Blak applies a small set of editor options at startup. They live in [`lua/blak/core/options.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/options.lua) and run before plugins load.

Anything here can be overridden in your `user.lua` (via the `editor.*` table) or by reassigning `vim.opt.*` after Blak's setup.

## What gets set

### Visual

| Option | Value | Why |
| --- | --- | --- |
| `termguicolors` | `true` | True-color rendering for the colorscheme + splash. |
| `number` | `true` | Line numbers. |
| `relativenumber` | from `editor.relative_number` (default `true`) | Relative line numbers; toggle with the config. |
| `cursorline` | `true` | Highlight the current line. |
| `signcolumn` | `"yes"` | Always show signcolumn so it doesn't shift. |
| `pumheight` | `12` | Cap completion popup height. |
| `wrap` | `false` | Hard newlines only. |
| `linebreak` | `true` | When wrap is on (you turned it on), break on word boundaries. |
| `breakindent` | `true` | Wrapped lines keep their indent. |
| `winborder` | from `ui.winborder` (default `"rounded"`) | Border for floating windows. LSP hover, diagnostic floats, the completion menu and docs, and plugin floats that read `'winborder'` all follow it. |

### Splits

| Option | Value | Why |
| --- | --- | --- |
| `splitbelow` | `true` | New horizontal splits go below. |
| `splitright` | `true` | New vertical splits go right. |

### Search

| Option | Value | Why |
| --- | --- | --- |
| `ignorecase` | `true` | Case-insensitive search… |
| `smartcase` | `true` | …unless the query has uppercase. |
| `inccommand` | `"split"` | `:s` previews matches live in a split. |
| `grepprg` | `rg --vimgrep --smart-case --hidden`, only when `rg` is executable | `:grep` uses ripgrep and respects ignore files (Neovim's own `rg` default passes `-uu`). Without `rg`, Neovim's `grep` fallback stays. `grepformat` is left to Neovim, which sets the matching value. |

### Persistence

| Option | Value | Why |
| --- | --- | --- |
| `undofile` | `true` | Persist undo across sessions. |
| `confirm` | from `editor.confirm` (default `true`) | Prompt before commands abandon unsaved changes. |
| `updatetime` | `250` | Faster CursorHold / swap writes — drives gitsigns blame, etc. |
| `timeoutlen` | `400` | Tighter mapping timeout for which-key. |

### Movement

| Option | Value | Why |
| --- | --- | --- |
| `scrolloff` | from `editor.scrolloff` (default `8`) | Keep context above/below cursor. |
| `sidescrolloff` | from `editor.sidescrolloff` (default `8`) | Same horizontally. |
| `smoothscroll` | `true` | Scroll by screen line, so long wrapped lines scroll smoothly. |
| `jumpoptions` | `"clean,view"` | Keep Neovim's default `clean` (unloaded buffers leave the jumplist) and restore the view when jumping. |

### Indent

| Option | Value | Why |
| --- | --- | --- |
| `tabstop` | from `editor.tabstop` (default `2`) | Spaces a tab character displays as. |
| `shiftwidth` | from `editor.shiftwidth` (default `2`) | Spaces for `<<` / `>>`. |
| `softtabstop` | from `editor.shiftwidth` (default `2`) | `<Tab>` and `<BS>` in insert mode move by one indent level. |
| `expandtab` | from `editor.expandtab` (default `true`) | Use spaces, not tabs. |

Blak leaves `autoindent` at Neovim's default (on) and does not set
`smartindent`. Language indentation comes from filetype indent plugins and
Treesitter `indentexpr`.

### Completion

| Option | Value | Why |
| --- | --- | --- |
| `completeopt` | `"menu,menuone,noselect,popup"` | Show the menu even for one match, don't auto-select, and show extra info in a popup. Blink.cmp draws its own menu; these apply to native completion such as `<C-x><C-o>`. |

### Clipboard

| Option | Value | Why |
| --- | --- | --- |
| `clipboard` | `"unnamedplus"` if `editor.clipboard` (default true) | Yank and paste use the system clipboard. With `editor.clipboard = false`, Blak removes `unnamed` and `unnamedplus`. |

## Overriding

In `user.lua`:

```lua
return {
  editor = {
    tabstop = 4,
    shiftwidth = 4,
    relative_number = false,
    confirm = false,
    clipboard = false,
    scrolloff = 4,
  },
}
```

Or set `vim.opt.*` directly after Blak loads:

```lua
vim.api.nvim_create_autocmd("User", {
  pattern = "BlakReady",
  callback = function()
    vim.opt.cursorline = false
    vim.opt.signcolumn = "number"
  end,
})
```

See [User events](/reference/events/).
