---
title: Keymaps
description: Every keymap registered by Blak core, where it lives, and the rule behind it.
---

The rule: **common operations get memorable mappings; uncommon operations get commands and pickers.** Every keymap has a description and appears in `:BlakKeys`.

The leader is `<Space>`. Local leader is `\`.

All core keymaps are defined in [`lua/blak/core/keymaps.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/keymaps.lua). Extras and `user.lua` can add more — they show up in `:BlakKeys` too.

## Custom keymaps

Add or override mappings from `lua/blak/user.lua` with the `keymaps` list:

```lua
return {
  keymaps = {
    { key = "<leader>sg", action = "<cmd>BlakPick grep<cr>", description = "Grep" },
    {
      mode = { "n", "x" },
      key = "<leader>y",
      action = '"+y',
      description = "Yank to clipboard",
    },
    {
      key = "<leader>rn",
      action = function()
        vim.lsp.buf.rename()
      end,
      description = "Rename symbol",
    },
    { key = "<leader>/", disable = true },
  },
}
```

Active entries require `description` so they stay discoverable through `:BlakKeys`.
Use `mode` for one mode or a list of modes, and use a command string or Lua
function for `action`. Use `disable = true` to disable a Blak mapping. To move a
default action, disable the old key and add the new one.

## Edit & navigation

| Mode | Mapping | Action |
| --- | --- | --- |
| n | `<Esc>` | Clear search highlight |
| n,i,x,s | `<C-s>` | Save (where Neovim leaves it free) |
| n,i,x,s | `<D-s>` | Save (where the UI forwards Command-s) |
| n | `<leader>qq` | Quit all (`:qa`) |

`<C-s>` and `<D-s>` are bound only if your config or a plugin hasn't already claimed them. See `map_if_available` in the source.

## Find (pickers)

| Mapping | Action |
| --- | --- |
| `<leader><space>` | Smart file find |
| `<leader>/` | Grep |
| `<leader>ff` | Find files |
| `<leader>fg` | Grep |
| `<leader>fb` | Buffers |
| `<leader>fr` | Recent files |
| `<leader>fc` | Commands |
| `<leader>fk` | Keymaps |
| `<leader>fh` | Help |

All dispatch through the picker provider — see [Pickers](/guide/pickers/).

## Buffers

| Mapping | Action |
| --- | --- |
| <code>&lt;leader&gt;&#96;</code> | Toggle last file (native alternate file) |
| `<leader>bd` | Delete buffer (via Snacks `bufdelete` if available) |
| `<leader>bn` | Next buffer |
| `<leader>bp` | Previous buffer |

## Windows

| Mapping | Action |
| --- | --- |
| `<leader>ws` | Split window below |
| `<leader>wv` | Split window right |

These use Neovim's native `:rightbelow split` and `:rightbelow vsplit`. Blak
only binds them when those keys are still free, so an existing user or plugin
mapping wins.

## Explorer

| Mapping | Action |
| --- | --- |
| `<leader>e` | Configured explorer (Oil by default; Snacks when `editor.snacks-explorer` is enabled) |

Blak leaves Neovim's native `-` motion alone.

## Terminal

| Mapping | Action |
| --- | --- |
| `<leader>tt` | Toggle the configured terminal provider |

Change this mapping with `terminal.toggle_key` in `lua/blak/user.lua`. Set it
to `false` to leave terminal toggling command-only.

## Git (gitsigns)

| Mode | Mapping | Action |
| --- | --- | --- |
| n | `]h` | Next hunk (or `]c` inside a diff) |
| n | `[h` | Previous hunk (or `[c` inside a diff) |
| n | `<leader>gs` | Stage hunk |
| v | `<leader>gs` | Stage selection range |
| n | `<leader>gr` | Reset hunk |
| v | `<leader>gr` | Reset selection range |
| n | `<leader>gS` | Stage buffer |
| n | `<leader>gR` | Reset buffer |
| n | `<leader>gp` | Preview hunk |
| n | `<leader>gb` | Blame line (full) |
| n | `<leader>gd` | Diff this |

## LSP (bound on LspAttach)

These map only when an LSP server attaches to the current buffer.

| Mapping | Action |
| --- | --- |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gI` | Go to implementation |
| `gr` | References |
| `K` | Hover |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename |
| `<leader>cf` | Format buffer (Conform → LSP fallback) |
| `<leader>cs` | Document symbols (picker) |
| `<leader>cS` | Workspace symbols (picker) |

See the [LSP guide](/guide/lsp/).

## Diagnostics

| Mapping | Action |
| --- | --- |
| `]d` | Next diagnostic (jumps + opens float) |
| `[d` | Previous diagnostic (jumps + opens float) |
| `<leader>xx` | Diagnostics picker |
| `<leader>xd` | Line diagnostic float |

## Blak & Lazy

| Mapping | Action |
| --- | --- |
| `<leader>ll` | `:Lazy` |
| `<leader>lo` | `:Blak` |
| `<leader>lc` | `:BlakConfig` |
| `<leader>lu` | `:BlakUpdate` |
| `<leader>lU` | `:BlakUpgrade` |
| `<leader>lr` | `:BlakRollback` |
| `<leader>ld` | `:BlakDoctor` |
| `<leader>le` | `:BlakExtras` |
| `<leader>lk` | `:BlakKeys` |
| `<leader>ln` | `:BlakNews` |
| `<leader>ls` | `:BlakSplash` |
| `<leader>lt` | `:BlakToolsInstall` |
| `<leader>lT` | `:BlakTreesitterInstall` |
| `<leader>?` | `:BlakKeys` |

## Toggles

| Mapping | Action |
| --- | --- |
| `<leader>uf` | Toggle format-on-save (buffer) |

`:BlakFormatToggle!` toggles it globally. See [Formatting](/guide/formatting/).

## Keymaps added or changed by extras

| Extra | Mapping | Action |
| --- | --- | --- |
| `editor.window-navigation` | `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | Move between windows |
| `ui.comfy-line-numbers` | label + `j` / `k` | Comfy vertical motions |
| `ui.comfy-line-numbers` | label + `<Down>` / `<Up>` | Comfy vertical motions |
| `ui.zen` | `<leader>uz` | Zen mode |
| `git.lazygit` | `<leader>gg` | LazyGit float |
| `git.diffview` | `<leader>gD` | DiffviewOpen |
| `git.diffview` | `<leader>gH` | File history |
| `ai.sidekick` | `<C-.>` | Focus Sidekick CLI |
| `ai.sidekick` | `<leader>aa` | Toggle Sidekick CLI |
| `ai.sidekick` | `<leader>as` | Select Sidekick CLI |
| `ai.sidekick` | `<leader>ad` | Detach Sidekick CLI session |
| `ai.sidekick` | `<leader>af` | Send file to Sidekick |
| `ai.sidekick` | `<leader>at` | Send current context to Sidekick |
| `ai.sidekick` | `<leader>av` | Send visual selection to Sidekick |
| `ai.sidekick` | `<leader>ap` | Pick Sidekick prompt |
| `editor.harpoon` | `<leader>ha` | Add current file to Harpoon |
| `editor.harpoon` | `<leader>hh` | Toggle Harpoon quick menu |
| `editor.harpoon` | `<leader>hp` / `<leader>hn` | Previous / next Harpoon file |
| `editor.harpoon` | `<leader>h1`-`<leader>h4` | Jump to Harpoon file |
| `editor.neotree` | `<leader>E` | Toggle Neo-tree |
| `editor.snacks-explorer` | `<leader>e` | Snacks explorer |
| `editor.snacks-terminal` | `terminal.toggle_key` | Snacks terminal |

## Design notes

- **No hidden chords.** If a Blak mapping isn't in this page or in `:BlakKeys`, it doesn't exist in core, enabled extras, or `user.lua`.
- **Mnemonic grouping.** `<leader>f*` find, `<leader>b*` buffers, `<leader>g*` git, `<leader>c*` code, `<leader>x*` diagnostics, `<leader>l*` Lazy/Blak, `<leader>t*` terminal, `<leader>u*` UI toggles, `<leader>w*` windows, `<leader>q*` quit.
- **`map_if_available`.** Keys like `<C-s>` and `<D-s>` are only set when not already mapped — they yield to native bindings or another plugin's claim.
- **Extras and user config add to or retarget this list.** Run `:BlakKeys` to see what your enabled extras and `user.lua` have registered.
