---
title: Keymaps
description: Every keymap registered by Blak core, where it lives, and the rule behind it.
---

The rule: **common operations get memorable mappings; uncommon operations get commands and pickers.** Every keymap has a description and appears in `:BlakKeys`.

The leader is `<Space>`. Local leader is `\`.

All core keymaps are defined in [`lua/blak/core/keymaps.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/keymaps.lua). Extras can add more — they show up in `:BlakKeys` too.

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
| `<leader>bd` | Delete buffer (via Snacks `bufdelete` if available) |
| `<leader>bn` | Next buffer |
| `<leader>bp` | Previous buffer |

## Explorer

| Mapping | Action |
| --- | --- |
| `<leader>e` | Oil explorer |

Blak leaves Neovim's native `-` motion alone.

## Terminal

| Mapping | Action |
| --- | --- |
| `<leader>tt` | Toggle a native terminal split |

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
| `<leader>lu` | `:BlakUpdate` |
| `<leader>lr` | `:BlakRollback` |
| `<leader>ld` | `:BlakDoctor` |
| `<leader>le` | `:BlakExtras` |
| `<leader>?` | `:BlakKeys` |

## Toggles

| Mapping | Action |
| --- | --- |
| `<leader>uf` | Toggle format-on-save (buffer) |

`:BlakFormatToggle!` toggles it globally. See [Formatting](/guide/formatting/).

## Keymaps added by extras

| Extra | Mapping | Action |
| --- | --- | --- |
| `ui.zen` | `<leader>uz` | Zen mode |
| `git.lazygit` | `<leader>gg` | LazyGit float |
| `git.diffview` | `<leader>gD` | DiffviewOpen |
| `git.diffview` | `<leader>gH` | File history |
| `editor.neotree` | `<leader>E` | Toggle Neo-tree |

## Design notes

- **No hidden chords.** If a mapping isn't in this page or in `:BlakKeys`, it doesn't exist in Blak core.
- **Mnemonic grouping.** `<leader>f*` find, `<leader>b*` buffers, `<leader>g*` git, `<leader>c*` code, `<leader>x*` diagnostics, `<leader>l*` Lazy/Blak, `<leader>t*` terminal, `<leader>u*` UI toggles, `<leader>q*` quit.
- **`map_if_available`.** Keys like `<C-s>` and `<D-s>` are only set when not already mapped — they yield to native bindings or another plugin's claim.
- **Extras add to this list.** Run `:BlakKeys` to see what your enabled extras have registered.
