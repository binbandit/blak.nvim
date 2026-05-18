---
title: User events
description: The User autocmds Blak emits and how to hook them from your config.
---

Blak fires user autocmds at well-defined points so your config can integrate
without monkey-patching internals. For ordinary `user.lua` tweaks, prefer
`hooks.after`; use events when external files or plugins need a stable signal.

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

## `BlakConfigReloaded`

Fired after a running Blak session reloads `lua/blak/user.lua`:

```lua
vim.api.nvim_exec_autocmds("User", { pattern = "BlakConfigReloaded", modeline = false })
```

Blak watches `lua/blak/user.lua` when it exists and also listens for writes from
inside Neovim. On reload it clears `package.loaded["blak.user"]`, rebuilds the
merged config, reapplies safe in-session runtime pieces, refreshes lazy.nvim's
spec graph, and emits this event.

Plugin additions/removals still need `:BlakExtras sync` or `:Lazy sync`.
Restarting is still the clean way to unload plugins, keymaps, and runtime hooks
that already ran.

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

For the same tweak directly in `user.lua`, use `hooks.after`:

```lua
return {
  hooks = {
    after = function()
      vim.opt.cursorline = false
      vim.keymap.set("n", "<leader>oo", "<cmd>Oil .<cr>", { desc = "Oil cwd" })
    end,
  },
}
```

Or use an `apply` hook on an [extra](/project/writing-extras/), which runs at
config-merge time.

## Snacks events Blak reacts to

Not emitted by Blak, but useful to know about — Blak listens for these to start / repaint the splash:

| Event | Source | What |
| --- | --- | --- |
| `User SnacksDashboardOpened` | Snacks | Dashboard buffer has rendered |
| `User SnacksDashboardUpdatePost` | Snacks | Dashboard has re-rendered |

## Lazy events Blak reacts to

| Event | Source | What |
| --- | --- | --- |
| `User LazyUpdatePre` | lazy.nvim | Fires before any `:Lazy update`. Blak writes a rollback snapshot. |

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
