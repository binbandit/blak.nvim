---
title: Public API
description: The Lua functions Blak exposes for your config to call directly.
---

Blak's runtime exposes a few small modules you can `require()` from your config. They're stable enough to depend on.

## `require("blak")`

### `setup(opts?)`

Entry point — called from `init.lua` on startup. You usually won't call it yourself, but if you want to defer initialization or pass overrides programmatically:

```lua
require("blak").setup({
  picker = { provider = "snacks" },
})
```

Returns nothing. Errors on validation failure. Sets `vim.g.blak_loaded = true` on success.

## `require("blak.config")`

### `get()`

Returns the merged, validated config table. Useful inside extras or autocmds:

```lua
local config = require("blak.config").get()
if config.ui.splash.enabled then ... end
```

### `setup(opts)`

Reapplies the merge with new opts. Generally only used by `require("blak").setup`.

### `reload()`

Clears the cached `blak.user` module, reapplies the original setup opts, and
returns the refreshed merged config. Blak calls this automatically when
`lua/blak/user.lua` changes.

### `run_hooks(config, phase)`

Runs `hooks.before` or `hooks.after` from a config table. Blak calls
`hooks.before` during config build and `hooks.after` after startup/reload, so
most users should set hooks in `user.lua` instead of calling this directly:

```lua
return {
  hooks = {
    after = function(config)
      vim.opt.cursorline = false
    end,
  },
}
```

## `require("blak.util")`

A grab bag of helpers Blak's own modules use. Stable enough for your config.

### Notifications

```lua
require("blak.util").notify("Hello", vim.log.levels.INFO)
require("blak.util").warn("Something off")
require("blak.util").error("Boom")
```

All notifications run through `vim.notify` with `"Blak"` as the title, scheduled so they're safe to call from inside fast events.

### Safe require

```lua
local mod, err = require("blak.util").try_require("not.here")
-- mod == nil, err is the load error
```

```lua
local conform = require("blak.util").load_plugin("conform.nvim", "conform")
if conform then conform.format() end
```

`load_plugin` tries `require` first, then `Lazy load` on the named plugin, then warns if neither works. This is how Blak's own keymaps call into optional plugins like `gitsigns` and `conform`.

### System

```lua
require("blak.util").executable("rg")          -- bool: is rg on $PATH
require("blak.util").sep()                     -- "/" or "\\"
require("blak.util").join("a", "b", "c")       -- "a/b/c"
```

### File I/O

```lua
local util = require("blak.util")
util.mkdir("/tmp/blak/cache")
local data = util.read_file(path)              -- nil if not found
util.write_file(path, data)                    -- creates parents
util.copy_file(from, to)
util.file_exists(path)
```

### Tables

```lua
util.unique({ "a", "b", "a", "" })             -- { "a", "b" } (deduped, sorted)
util.extend_list(dst, src)                     -- in-place extend + unique
util.tbl_keys(tbl)                             -- sorted key list
```

### Git

```lua
local root = require("blak.util").git_root()   -- git root, falling back to cwd
```

Uses `vim.fs.root` when available, falls back to `git rev-parse --show-toplevel`, then to the current working directory.

## `require("blak.core.terminal")`

```lua
require("blak.core.terminal").toggle()
require("blak.core.terminal").toggle({ cmd = "lazygit" })
```

Opens or closes the configured terminal provider. Native terminal splits are
the default; when `terminal.provider = "snacks"`, the same API dispatches to
`Snacks.terminal.toggle()`.

### UI

```lua
require("blak.util").open_scratch("Title", { "line 1", "line 2" })
```

Opens a read-only, unlisted scratch buffer in a split. Used by `:Blak`, `:BlakKeys`, and `:BlakNews`. `:BlakExtras` has a dedicated floating UI.

## `require("blak.extras")`

### `enabled(config)`

Returns the merged list of enabled extra IDs (from `config.extras.enabled` plus the state file).

### `apply(config)`

Applies every enabled extra's contributions to the config table in place. Called once during setup.

## `require("blak.core.update")`

```lua
local update = require("blak.core.update")
update.backup()       -- snapshot the lockfile now
update.update()       -- :BlakUpdate
update.rollback()     -- :BlakRollback
update.upgrade()      -- :BlakUpgrade
update.news()         -- :BlakNews
```

## `require("blak.providers.picker")`

```lua
require("blak.providers.picker").pick("files")
require("blak.providers.picker").pick("smart")
```

Use this if you want to bind a custom keymap to a picker call.

## `require("blak.splash")`

```lua
require("blak.splash").preview()                 -- :BlakSplash
require("blak.splash").header()                  -- string array for a dashboard header
require("blak.splash").play(bufnr, opts)         -- animate in any buffer
```

## Vim globals Blak sets

| Global | Type | Meaning |
| --- | --- | --- |
| `g:blak_loaded` | boolean | True after `setup()` completes. |
| `g:blak_loading` | boolean | True while setup is in flight. |
| `g:blak_disable_autoformat` | boolean | Disable format-on-save globally. |
| `g:blak_config` | table | Optional table merged before `user.lua`. |

| Buffer var | Meaning |
| --- | --- |
| `b:blak_disable_autoformat` | Disable format-on-save for this buffer. |
| `b:blak_splash_playing` | Splash animation guard flag. |
