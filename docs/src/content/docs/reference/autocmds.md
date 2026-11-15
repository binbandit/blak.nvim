---
title: Autocmds
description: Every autocmd Blak registers, the group it lives in, and what it does.
---

Blak registers a small set of autocmds across the runtime. Each one lives in a named augroup so it can be cleared without affecting others.

Source: [`lua/blak/core/autocmds.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/autocmds.lua) plus a few inline in other modules.

## Core (`BlakCore` group)

### `TextYankPost` — flash on yank

Highlights the yanked region for 180 ms so you see exactly what was captured.

```lua
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 180 })
  end,
})
```

### `VimResized` — equalize splits

When the terminal resizes, re-equalize all windows so panes don't stay lopsided.

### `BufReadPost` — restore cursor

After opening the current editing buffer, jump to its last known position.
Background reads and special buffers do not move the visible cursor.

### `FileType` — close on `q`

For `help`, `qf`, `man`, `checkhealth`: unlist the buffer and bind `q` to close it.

## Splash (`BlakSplash` group)

### `BufEnter` / `WinEnter` - hide the ruler on the dashboard

Snacks hides the statusline on the startup dashboard, so Neovim would draw the
ruler in the command line. While the dashboard (or a float over it) is focused,
Blak turns `'ruler'` off; it restores your value when a regular window takes
focus.

### `User SnacksDashboardUpdatePre`

Pauses the splash animation while Snacks re-renders the dashboard.

### `User SnacksDashboardOpened` / `SnacksDashboardUpdatePost`

Starts (or repaints) the black-hole animation on the dashboard buffer, and sets
the dashboard window's local `fillchars` to `eob: ` so no `~` rows show under it.
See [Splash](/guide/splash/).

Registered in [`lua/blak/splash/init.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/splash/init.lua).

## Splash colors (`BlakSplashColors` group)

### `ColorScheme` - restore splash colors

`:colorscheme` runs `:hi clear`, which removes the splash highlight groups. Blak
defines them again after every colorscheme change, so the splash keeps its
colors.

Registered in [`lua/blak/splash/init.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/splash/init.lua).

## LSP (`BlakLspKeys` group)

### `LspAttach` — bind LSP keymaps

When a server attaches to a buffer, bind the buffer-local LSP keymaps (`gd`, `gD`, `<leader>ca`, `<leader>cr`, `<leader>cs`, `<leader>cS`). Hover, references, implementation, and the other `gr*` maps are Neovim's own LSP defaults. Formatting (`<leader>cf`) is available globally through Conform.

Registered in [`lua/blak/core/keymaps.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/keymaps.lua).

## Update (`BlakUpdate` group)

### `User LazyUpdatePre` — snapshot rollback state

Before any `:Lazy update`, write a rollback snapshot under `stdpath('state')/blak/rollbacks/`. The snapshot includes `lazy-lock.json`, `lua/blak/user.lua`, enabled extras state, upgrade migration state, and accepted update state. This means even a manual `:Lazy update` is protected.

Registered in [`lua/blak/core/update.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/update.lua).

## Treesitter

### `FileType` — start treesitter

Lazy-attaches treesitter to a buffer if the buffer's line count is under `performance.max_treesitter_lines`. Also sets `indentexpr` to nvim-treesitter's indent.

Registered in [`lua/blak/core/treesitter.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/treesitter.lua).

## User events emitted by Blak

| Event | When | Where |
| --- | --- | --- |
| `User BlakReady` | After core setup and plugin registration; lazy plugins load later. | [`lua/blak/init.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/init.lua) |

See [User events](/reference/events/) for how to hook them.

## Augroup discipline

Every Blak group is created with `clear = true` so re-sourcing the config doesn't double-register handlers:

```lua
vim.api.nvim_create_augroup("BlakCore", { clear = true })
```

If you write your own integrations against Blak, do the same.
