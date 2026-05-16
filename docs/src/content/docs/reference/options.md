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
| `grepprg` | `rg --vimgrep --smart-case --hidden` | `:grep` uses ripgrep. |

### Persistence

| Option | Value | Why |
| --- | --- | --- |
| `undofile` | `true` | Persist undo across sessions. |
| `updatetime` | `250` | Faster CursorHold / swap writes — drives gitsigns blame, etc. |
| `timeoutlen` | `400` | Tighter mapping timeout for which-key. |

### Movement

| Option | Value | Why |
| --- | --- | --- |
| `scrolloff` | from `editor.scrolloff` (default `8`) | Keep context above/below cursor. |
| `sidescrolloff` | from `editor.sidescrolloff` (default `8`) | Same horizontally. |
| `smoothscroll` | `true` (if available) | Smooth scroll on Neovim 0.10+. |
| `jumpoptions` | `"view"` (if available) | Jumps remember view position. |

### Indent

| Option | Value | Why |
| --- | --- | --- |
| `tabstop` | from `editor.tabstop` (default `2`) | Spaces a tab character displays as. |
| `shiftwidth` | from `editor.shiftwidth` (default `2`) | Spaces for `<<` / `>>`. |
| `expandtab` | from `editor.expandtab` (default `true`) | Use spaces, not tabs. |

### Completion

| Option | Value | Why |
| --- | --- | --- |
| `completeopt` | `"menu,menuone,noselect"` | Show menu always, don't auto-select. |

### Clipboard

| Option | Value | Why |
| --- | --- | --- |
| `clipboard` | `"unnamedplus"` if `editor.clipboard` (default true) | Yank and paste use the system clipboard. |

## Overriding

In `user.lua`:

```lua
return {
  editor = {
    tabstop = 4,
    shiftwidth = 4,
    relative_number = false,
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

See [User events](/blak.nvim/reference/events/).
