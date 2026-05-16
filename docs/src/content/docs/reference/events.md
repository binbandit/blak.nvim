---
title: User events
description: The User autocmds Blak emits and how to hook them from your config.
---

Blak fires user autocmds at well-defined points so your `user.lua` can integrate without monkey-patching internals.

## `BlakReady`

Fired once at the end of `require("blak").setup()` after every subsystem has loaded:

```lua
-- lua/blak/init.lua
vim.api.nvim_exec_autocmds("User", { pattern = "BlakReady", modeline = false })
```

By the time `BlakReady` fires:

- Config is merged and validated.
- Editor options are applied.
- Core autocmds, commands, keymaps are registered.
- Splash integration is hooked.
- `lazy.nvim` is loaded; plugins are either ready or queued to load on their lazy triggers.

### Example: post-startup tweaks

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  -- regular Blak overrides go here
}
```

```lua
-- in an autocmd file you load yourself, e.g. lua/blak/local.lua:
vim.api.nvim_create_autocmd("User", {
  pattern = "BlakReady",
  callback = function()
    vim.opt.cursorline = false
    vim.keymap.set("n", "<leader>oo", "<cmd>Oil .<cr>", { desc = "Oil cwd" })
  end,
})
```

Or in an `apply` hook on an [extra](/project/writing-extras/), which runs at config-merge time.

## Snacks events Blak reacts to

Not emitted by Blak, but useful to know about — Blak listens for these to start / repaint the splash:

| Event | Source | What |
| --- | --- | --- |
| `User SnacksDashboardOpened` | Snacks | Dashboard buffer has rendered |
| `User SnacksDashboardUpdatePost` | Snacks | Dashboard has re-rendered |

## Lazy events Blak reacts to

| Event | Source | What |
| --- | --- | --- |
| `User LazyUpdatePre` | lazy.nvim | Fires before any `:Lazy update`. Blak snapshots `lazy-lock.json`. |

You can hook these too:

```lua
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyUpdatePre",
  callback = function()
    print("about to update")
  end,
})
```

## Want another event?

Open an issue with the use case — Blak is happy to fire user autocmds at any well-defined moment. The bar is just "stable and useful for downstream integration."
