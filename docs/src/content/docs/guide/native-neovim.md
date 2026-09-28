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

Use native commands to restart attached clients or control a configured server:

```vim
:lsp restart
:lsp enable tsc
:lsp disable tsc
```

Session enable/disable choices do not change `user.lua` or saved extras.
`:BlakKeys` includes described native defaults such as `grn` for rename and
`grt` for type definition, alongside Blak's existing shortcuts. The
[LSP reference](https://neovim.io/doc/user/lsp/) covers native commands and mappings.

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
      vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserNativeCompletion", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/completion", event.buf) then
            vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
          end
        end,
      })
    end,
  },
}
```

Restart after applying this. Completion opens on the server's trigger
characters; `<C-x><C-o>` requests it explicitly. Use `<C-n>`/`<C-p>` to move
and `<C-y>` to accept. This recipe supplies native LSP completion, with different
sources, matching, and bracket behavior from Blink. See
[`vim.lsp.completion`](https://neovim.io/doc/user/lsp/#lsp-completion).

Remove the recipe and restart to restore Blink. For optional plugins affected
by that change, run `:Lazy sync` as usual.

## Why the package manager stays

Neovim 0.12 ships `vim.pack`; its [official documentation](https://neovim.io/doc/user/pack/)
still labels it experimental. Blak's current Lazy setup provides deferred
loading, extra plugin specifications, user overrides, and tested updates and
rollback. A native backend needs to preserve those guarantees before becoming
a supported choice. Stable updates retain the current backend.
