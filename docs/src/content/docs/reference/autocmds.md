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
    vim.highlight.on_yank({ timeout = 180 })
  end,
})
```

### `VimResized` — equalize splits

When the terminal resizes, re-equalize all windows so panes don't stay lopsided.

### `BufReadPost` — restore cursor

After opening a buffer, jump to the cursor's last known position (skips help buffers and empty marks).

### `FileType` — close on `q`

For `help`, `qf`, `man`, `checkhealth`, `lspinfo`, `notify`: unlist the buffer and bind `q` to close it.

## Splash (`BlakSplash` group)

### `User SnacksDashboardOpened` / `SnacksDashboardUpdatePost`

Starts (or repaints) the black-hole animation on the dashboard buffer. See [Splash](/guide/splash/).

Registered in [`lua/blak/splash/init.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/splash/init.lua).

## LSP (`BlakLspKeys` group)

### `LspAttach` — bind LSP keymaps

When a server attaches to a buffer, bind the buffer-local LSP keymaps (`gd`, `gD`, `gI`, `gr`, `K`, `<leader>ca`, `<leader>cr`, `<leader>cs`, `<leader>cS`, `<leader>cf`).

Registered in [`lua/blak/core/keymaps.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/keymaps.lua).

## Update (`BlakUpdate` group)

### `User LazyUpdatePre` — snapshot rollback state

Before any `:Lazy update`, write a rollback snapshot under `$XDG_STATE_HOME/blak/rollbacks/`. The snapshot includes `lazy-lock.json`, `lua/blak/user.lua`, enabled extras state, upgrade migration state, and accepted update state. This means even a manual `:Lazy update` is protected.

Registered in [`lua/blak/core/update.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/update.lua).

## Treesitter

### `FileType` — start treesitter

Lazy-attaches treesitter to a buffer if the buffer's line count is under `performance.max_treesitter_lines`. Also sets `indentexpr` to nvim-treesitter's indent.

Registered in [`lua/blak/core/treesitter.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/treesitter.lua).

## User events emitted by Blak

| Event | When | Where |
| --- | --- | --- |
| `User BlakReady` | After Blak's setup completes (all subsystems wired). | [`lua/blak/init.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/init.lua) |

See [User events](/reference/events/) for how to hook them.

## Augroup discipline

Every Blak group is created with `clear = true` so re-sourcing the config doesn't double-register handlers:

```lua
vim.api.nvim_create_augroup("BlakCore", { clear = true })
```

If you write your own integrations against Blak, do the same.
