---
title: Extras
description: Every Blak extra, what it ships, and the contract for writing your own.
---

Extras are how Blak says "yes" to language support, optional tools, and personal preference — without bloating core for everyone.

All extras live under [`lua/blak/extras/`](https://github.com/binbandit/blak.nvim/tree/main/lua/blak/extras), registered in [`lua/blak/extras/init.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/extras/init.lua).

## The contract

An extra is a single Lua module that can contribute any of:

- Treesitter parsers (`ensure_installed`)
- Mason tools (`mason.ensure_installed`)
- LSP servers via `vim.lsp.config()`
- Formatters and linters by filetype
- Snacks module options
- Keymaps (auto-shown in `:BlakKeys`)
- Plugin specs for lazy.nvim

When you disable an extra and restart, Blak stops registering that extra's plugin specs, keymaps, tools, parsers, and config contributions. Run `:BlakExtras sync` afterward to let lazy.nvim clean up removed plugins.

## Managing extras

```vim
:BlakExtras                       " open the extras UI
:BlakExtras list                  " same UI, explicit
:BlackExtras list                 " same command, typo-friendly
:BlakExtras enable lang.rust
:BlakExtras disable git.lazygit
:BlakExtras sync                  " run :Lazy sync after changes
```

The UI groups enabled extras and available extras, shows the tools and plugins
each one contributes, and lets you toggle the row under the cursor with `x` or
`<CR>`. Press `s` to sync lazy.nvim, `r` to refresh, and `q` to close. Extras
from `lua/blak/user.lua` are marked `[config]`; remove them there when you want
the UI to stop treating them as enabled.

State persists outside the repo in `stdpath('state')/blak/extras.json`. That means:

- A fresh clone with the same `NVIM_APPNAME` reuses the same enabled extras.
- A fresh install under a new `NVIM_APPNAME` starts from your config defaults.
- Multiple checkouts (`blak`, `blak-dev`) can have different enabled sets.
- `user.lua` and `extras.json` compose: anything in `extras.enabled` in `user.lua` is added on top of the state file.

If an extra was renamed or removed, `:BlakDoctor` reports it as unknown. Run `:BlakExtras disable <id>` to remove that stale state entry.

After enabling an extra:

1. Blak applies its config to the current session.
2. **Run `:BlakExtras sync` or `:Lazy sync`** if plugins were added.
3. **Run `:BlakToolsInstall`** to install any new Mason tools required.
4. **Run `:BlakDoctor`** to confirm everything resolved.

After disabling an extra, the state file updates immediately. Restart Blak when you want already-loaded plugins, keymaps, and runtime hooks to disappear from the current session, then run `:BlakExtras sync` if plugin specs were removed.

## Dedicated pages

Each supported extra has a dedicated page with its `user.lua` enable snippet,
configuration examples, install notes, and verification path.

| Group | Extras |
| --- | --- |
| Languages | [`lang.lua`](/extras/lang/lua/), [`lang.typescript`](/extras/lang/typescript/), [`lang.typescript-tsgo`](/extras/lang/typescript-tsgo/), [`lang.python`](/extras/lang/python/), [`lang.rust`](/extras/lang/rust/), [`lang.go`](/extras/lang/go/), [`lang.markdown`](/extras/lang/markdown/) |
| UI | [`ui.animations`](/extras/ui/animations/), [`ui.base46`](/extras/ui/base46/), [`ui.comfy-line-numbers`](/extras/ui/comfy-line-numbers/), [`ui.dim`](/extras/ui/dim/), [`ui.image-preview`](/extras/ui/image-preview/), [`ui.lualine`](/extras/ui/lualine/), [`ui.zen`](/extras/ui/zen/) |
| Git | [`git.lazygit`](/extras/git/lazygit/), [`git.diffview`](/extras/git/diffview/) |
| AI | [`ai.copilot`](/extras/ai/copilot/), [`ai.sidekick`](/extras/ai/sidekick/) |
| Editor | [`editor.mini`](/extras/editor/mini/), [`editor.window-navigation`](/extras/editor/window-navigation/), [`editor.neotree`](/extras/editor/neotree/), [`editor.snacks-explorer`](/extras/editor/snacks-explorer/), [`editor.snacks-terminal`](/extras/editor/snacks-terminal/), [`editor.telescope`](/extras/editor/telescope/), [`editor.fzf-lua`](/extras/editor/fzf-lua/) |

## Languages

### `lang.lua`

Lua development — what Blak itself is written in.

| Adds | Value |
| --- | --- |
| Treesitter | `lua`, `luadoc` |
| Mason | `stylua` |
| LSP | `lua_ls` |
| Format | `stylua` for `.lua` |

### `lang.typescript`

TypeScript and JavaScript with ESLint + Prettier.

| Adds | Value |
| --- | --- |
| Treesitter | `javascript`, `typescript`, `tsx`, `jsdoc`, `json`, `jsonc` |
| Mason | `prettier`, `prettierd`, `eslint_d` |
| LSP | `ts_ls`, `eslint` |
| Format | `prettierd` (fallback `prettier`) for js/ts/jsx/tsx/json |
| Lint | `eslint_d` for js/ts/jsx/tsx |

### `lang.typescript-tsgo`

TypeScript and JavaScript with the experimental native `tsgo` LSP, ESLint, and Prettier.

Enable this instead of `lang.typescript` when you want to try TypeScript's Go-based language server. If both are enabled and this extra applies after `lang.typescript`, it removes `ts_ls` from the merged config for future setup. Restart after switching if `ts_ls` already attached in the current session.

| Adds | Value |
| --- | --- |
| Treesitter | `javascript`, `typescript`, `tsx`, `jsdoc`, `json`, `jsonc` |
| Mason | `prettier`, `prettierd`, `eslint_d` |
| LSP | `tsgo`, `eslint` |
| Format | `prettierd` (fallback `prettier`) for js/ts/jsx/tsx/json |
| Lint | `eslint_d` for js/ts/jsx/tsx |

### `lang.python`

Python with Pyright + Ruff + Black + isort.

| Adds | Value |
| --- | --- |
| Treesitter | `python` |
| Mason | `black`, `isort`, `ruff` |
| LSP | `pyright`, `ruff` |
| Format | `isort`, then `black` |
| Lint | `ruff` |

### `lang.rust`

Rust with rust-analyzer and TOML support.

| Adds | Value |
| --- | --- |
| Treesitter | `rust`, `toml` |
| Mason | `codelldb` |
| LSP | `rust_analyzer` (with `cargo.allFeatures` + Clippy), `taplo` |
| Format | `rustfmt` (LSP fallback), `taplo` (LSP fallback) |
| Plugins | `saecki/crates.nvim` |

### `lang.go`

Go with gopls and golangci-lint.

| Adds | Value |
| --- | --- |
| Treesitter | `go`, `gomod`, `gosum`, `gowork` |
| Mason | `goimports`, `gofumpt`, `golangci-lint` |
| LSP | `gopls` |
| Format | `goimports`, `gofumpt` |
| Lint | `golangcilint` |

### `lang.markdown`

Markdown with Marksman LSP and Prettier.

| Adds | Value |
| --- | --- |
| Treesitter | `markdown`, `markdown_inline` |
| Mason | `prettier`, `prettierd`, `markdownlint` |
| LSP | `marksman` |
| Format | `prettierd` (fallback `prettier`) for markdown |
| Lint | `markdownlint` |

## UI

### `ui.animations`

Smooth scroll and cursor animations via Snacks.

| Adds | Value |
| --- | --- |
| Snacks | `animate.enabled = true`, `scroll.enabled = true` |

### `ui.base46`

[AvengeMedia/base46](https://github.com/AvengeMedia/base46), the NvChad Base46 colorscheme collection as regular Neovim colorschemes.

| Adds | Value |
| --- | --- |
| Plugin | `AvengeMedia/base46` |

Enable the extra, sync plugins, then set `ui.colorscheme` to a Base46 scheme such as `base46-gruvchad`.

### `ui.comfy-line-numbers`

[mluders/comfy-line-numbers.nvim](https://github.com/mluders/comfy-line-numbers.nvim) shows relative line labels using left-hand digits and maps those labels back to vertical motions.

| Adds | Value |
| --- | --- |
| Plugin | `mluders/comfy-line-numbers.nvim` |
| Keymap | label + `j` or `k` motions |
| Keymap | label + `<Down>` or `<Up>` motions |

Enable the extra, sync plugins, then use the displayed labels with `j`, `k`, `<Down>`, or `<Up>`. For example, `11j` and `11<Down>` both move to the line whose comfy label is `11`.

### `ui.dim`

[Snacks dim](https://github.com/folke/snacks.nvim/blob/main/docs/dim.md) highlights the active scope by dimming the surrounding lines.

| Adds | Value |
| --- | --- |
| Snacks | `dim.enabled = true` |

Snacks already ships in core, so this extra enables the dim module without adding a plugin spec.

### `ui.image-preview`

Image previews in pickers and floats — works in Kitty, WezTerm, and Ghostty.

| Adds | Value |
| --- | --- |
| Snacks | `image.enabled = true` |

### `ui.lualine`

[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) as an opt-in statusline.

| Adds | Value |
| --- | --- |
| Plugin | `nvim-lualine/lualine.nvim` |
| Deps | `mini.icons` |
| Config | global statusline, Blak theme auto-detection, ASCII separators |

This extra turns off native `showmode` while lualine is enabled because the statusline already displays the current mode. Disable the extra, restart Blak, then run `:BlakExtras sync` to remove the plugin spec.

### `ui.zen`

Distraction-free editing mode.

| Adds | Value |
| --- | --- |
| Snacks | `zen.enabled = true` |
| Keymap | `<leader>uz` → toggle zen |

## Git

### `git.lazygit`

LazyGit floating window via Snacks.

| Adds | Value |
| --- | --- |
| Snacks | `lazygit.enabled = true` |
| Keymap | `<leader>gg` → LazyGit float |

Requires `lazygit` in `$PATH`.

### `git.diffview`

[sindrets/diffview.nvim](https://github.com/sindrets/diffview.nvim) for richer diffs and file history.

| Adds | Value |
| --- | --- |
| Plugin | `sindrets/diffview.nvim` |
| Keymap | `<leader>gD` → `:DiffviewOpen` |
| Keymap | `<leader>gH` → file history |

## AI

### `ai.copilot`

GitHub Copilot integration via [zbirenbaum/copilot.lua](https://github.com/zbirenbaum/copilot.lua).

| Adds | Value |
| --- | --- |
| Plugin | `zbirenbaum/copilot.lua` |

> Never enabled by default. Opt in with `:BlakExtras enable ai.copilot`.

### `ai.sidekick`

[sidekick.nvim](https://github.com/folke/sidekick.nvim) AI CLI terminals and optional Copilot Next Edit Suggestions.

| Adds | Value |
| --- | --- |
| Plugin | `folke/sidekick.nvim` |
| Snacks | `picker.actions.sidekick_send` |
| Keymap | `<C-.>` → focus the Sidekick CLI |
| Keymap | `<leader>aa` → toggle the CLI |
| Keymap | `<leader>as` → select an AI CLI |
| Keymap | `<leader>ad` → detach the current CLI session |
| Keymap | `<leader>af` → send the current file |
| Keymap | `<leader>at` → send `{this}` context |
| Keymap | `<leader>av` → send the visual selection |
| Keymap | `<leader>ap` → pick a prompt |

Enable it, sync plugins, then install at least one AI CLI supported by Sidekick, such as Codex, Claude, Gemini, or OpenCode:

```vim
:BlakExtras enable ai.sidekick
:BlakExtras sync
:checkhealth sidekick
```

Blak keeps `ai.sidekick.nes.enabled = false` by default so the extra remains a terminal-based AI workflow unless you opt into Copilot Next Edit Suggestions:

```lua
return {
  extras = { enabled = { "ai.sidekick" } },
  ai = {
    sidekick = {
      nes = { enabled = true },
      cli = {
        mux = { enabled = true, backend = "tmux" },
      },
    },
  },
}
```

The extra registers a Snacks picker action named `sidekick_send`. If you want a picker-local key for sending file/search selections to Sidekick, add it yourself so it remains part of your visible config:

```lua
return {
  extras = { enabled = { "ai.sidekick" } },
  snacks = {
    picker = {
      win = {
        input = {
          keys = {
            ["<a-a>"] = { "sidekick_send", mode = { "n", "i" } },
          },
        },
      },
    },
  },
}
```

> Never enabled by default. Disable it, restart Blak, then run `:BlakExtras sync` to remove the plugin spec.

## Editor

### `editor.mini`

[nvim-mini](https://github.com/nvim-mini/mini.nvim) modules as opt-in editor pieces.

| Adds | Value |
| --- | --- |
| Plugins | one `nvim-mini/mini.<module>` spec for each configured non-core `mini.modules` entry |
| Config | calls `require("mini.<module>").setup(mini.opts.<module> or {})` |

This extra does not enable any optional Mini module by default. `mini.icons` and
`mini.pairs` ship in core; put the other modules you want in `mini.modules`,
enable `editor.mini`, then run `:BlakExtras sync`.

### `editor.window-navigation`

Native window movement on Ctrl-h/j/k/l.

| Adds | Value |
| --- | --- |
| Keymaps | `<C-h>` left, `<C-j>` down, `<C-k>` up, `<C-l>` right |

This is an extra instead of a core default because `<C-l>` redraws the screen in
stock Neovim. Opting in keeps the shortcut explicit and reversible.

### `editor.neotree`

[nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) as an alternative file explorer alongside Oil.

| Adds | Value |
| --- | --- |
| Plugin | `nvim-neo-tree/neo-tree.nvim` (v3.x) |
| Deps | `plenary.nvim`, `mini.icons`, `nui.nvim` |
| Keymap | `<leader>E` → toggle Neo-tree |

### `editor.snacks-explorer`

[Snacks explorer](https://github.com/folke/snacks.nvim/blob/main/docs/explorer.md) as the configured file explorer.

| Adds | Value |
| --- | --- |
| Config | sets `explorer.provider = "snacks"` |
| Snacks | `explorer.enabled = true`; explorer picker `auto_close = true` |
| Binary | `fd` on `$PATH` for fast file discovery |
| Keymap | `<leader>e` → toggle Snacks explorer |

Snacks already ships in core for dashboard/input/notifier/picker support, so this extra enables the explorer module instead of adding a new plugin. Blak also toggles an already-open Snacks explorer instead of opening a second one.

### `editor.snacks-terminal`

[Snacks terminal](https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md) as the configured terminal provider.

| Adds | Value |
| --- | --- |
| Config | sets `terminal.provider = "snacks"` |
| Snacks | `terminal.enabled = true` |
| Command | `:BlakTerminal [cmd]` uses `Snacks.terminal.toggle()` |
| Keymap | `terminal.toggle_key` toggles Snacks terminal |

Snacks already ships in core, so this extra enables the terminal module and keeps the existing Blak command and keymap surface.

### `editor.telescope`

[nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) as the picker backend.

| Adds | Value |
| --- | --- |
| Plugin | `nvim-telescope/telescope.nvim` |
| Deps | `plenary.nvim`, `mini.icons` |
| Config | sets `picker.provider = "telescope"` |

Enabling this swaps `:BlakPick` and all `<leader>f*` mappings to Telescope.

### `editor.fzf-lua`

[ibhagwan/fzf-lua](https://github.com/ibhagwan/fzf-lua) as the picker backend.

| Adds | Value |
| --- | --- |
| Plugin | `ibhagwan/fzf-lua` |
| Deps | `mini.icons` |
| Config | sets `picker.provider = "fzf_lua"` |

## Anatomy of an extra

```lua
-- lua/blak/extras/lang/rust.lua
return {
  id = "lang.rust",
  label = "Rust",
  description = "rust-analyzer + treesitter",
  treesitter = { "rust", "toml" },
  mason = { "codelldb" },
  lsp = {
    servers = {
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = { check = { command = "clippy" } },
        },
      },
    },
  },
  format = {
    formatters_by_ft = { rust = { lsp_format = "fallback" } },
  },
  keys = {
    { lhs = "<leader>cc", rhs = ":!cargo check<CR>", desc = "cargo check" },
  },
  plugins = { -- optional, lazy.nvim spec list
    { "owner/plugin.nvim", opts = {} },
  },
  apply = function(config) -- optional, runs after merge
    config.snacks.dim = { enabled = true }
  end,
}
```

That's the entire surface. See [Writing an extra](/project/writing-extras/) for the full guide.
