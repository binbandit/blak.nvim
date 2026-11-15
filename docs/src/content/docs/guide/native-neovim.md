---
title: Native Neovim tools
description: Use Neovim 0.12's built-in tools and try native completion without changing Blak's defaults.
---

Blak's baseline is stable Neovim 0.12+. The following features ship with
Neovim and need no downloaded plugin. Check `:version` and `:help news` for
the capabilities of your installed release.

## Undo history

Load the bundled undo-tree viewer for the current session:

```vim
:packadd nvim.undotree
:Undotree
```

The viewer opens a split; moving through its entries changes the source
buffer's undo state. Run `:Undotree` again to close it. Blak already enables
persistent undo. See Neovim's [undo-tree plugin reference](https://neovim.io/doc/user/plugins/#package-undotree).

## Compare files or directories

```vim
:packadd nvim.difftool
:DiffTool path/to/old path/to/new
```

This opens Neovim's bundled comparison UI. Use it for file or directory
comparisons without installing another diff plugin. See the
[native difftool reference](https://neovim.io/doc/user/plugins/#difftool).

Both packages stay opt-in. To load one every startup, put its `vim.cmd.packadd`
call in `hooks.after`. Remove that call and restart to return to the default.

## LSP recovery and shortcuts

Use native commands to inspect, restart, or control a configured server:

```vim
:checkhealth vim.lsp     " clients, attached buffers, settings, and the log path
:lsp restart
:lsp stop
:lsp enable tsc
:lsp disable tsc
```

nvim-lspconfig's old `:LspInfo`, `:LspStart`, `:LspStop`, `:LspRestart`, and
`:LspLog` commands do not exist on Neovim 0.12; use the commands above instead.
Session enable/disable choices do not change `user.lua` or saved extras.

Neovim's LSP defaults handle most code navigation: `K` hover, `grr` references,
`gri` implementation, `grn` rename, `gra` code action, `grt` type definition,
and `gO` for a document outline in the location list. `:BlakKeys` lists them
alongside Blak's own shortcuts. The
[LSP reference](https://neovim.io/doc/user/lsp/) covers native commands and mappings.

## Select by syntax node

In visual mode, `an` expands the selection to the surrounding Treesitter node
and `in` shrinks it to a child node; repeat either to keep going. `]n` and `[n`
select the next and previous node. Without a Treesitter parser they fall back
to the language server's selection ranges. Use them after `v`, or with an
operator such as `dan`. See `:help v_an`.

## Restart in place

`:restart` restarts Neovim and restores the current session, which is the
quickest way to apply a change that needs a restart. `:restart!` starts fresh
without restoring the session, and `ZR` is the normal-mode shortcut.

## Try native LSP completion

Blink remains Blak's default. For a smaller native completion workflow, merge
this into `user.lua`, keeping your existing hooks and plugin specs:

```lua
return {
  plugins = {
    specs = { { "saghen/blink.cmp", enabled = false } },
  },
  hooks = {
    after = function()
      vim.o.autocomplete = true
      vim.o.pumborder = vim.o.winborder
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserNativeCompletion", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/completion", event.buf) then
            vim.lsp.completion.enable(true, client.id, event.buf)
            -- Complete from the server only, so buffer words don't duplicate its items.
            vim.bo[event.buf].complete = "o"
          end
        end,
      })
    end,
  },
}
```

Run `:restart` after applying this. `'autocomplete'` opens the menu as you
type. In buffers with a language server, `'complete'` is set to `"o"`, so the
menu shows the server's items through `vim.lsp.omnifunc`; other buffers keep
Neovim's default buffer-word sources. Use `<C-n>`/`<C-p>` to move and `<C-y>`
to accept. Blak's `completeopt` already includes `popup`, so selecting an item
shows its documentation, and `'pumborder'` borders the menu like other floats.
Add `vim.opt.completeopt:append("fuzzy")` for fuzzy matching.

With lua_ls on Neovim 0.12, the first as-you-type request of a session can
show no menu; the next keystroke brings it up. Native completion has no snippet source, ghost text, auto-brackets, or
separate signature window (`<C-s>` in insert mode shows signature help). See
[`vim.lsp.completion`](https://neovim.io/doc/user/lsp/#lsp-completion) and
`:help ins-autocompletion`.

Remove the recipe and run `:restart` to restore Blink. For optional plugins affected
by that change, run `:BlakExtras sync` as usual.

## Why the package manager stays

Neovim 0.12 ships `vim.pack`; its [official documentation](https://neovim.io/doc/user/pack/)
still labels it experimental. Blak's current Lazy setup provides deferred
loading, extra plugin specifications, user overrides, and tested updates and
rollback. A native backend needs to preserve those guarantees before becoming
a supported choice. Stable updates retain the current backend.
