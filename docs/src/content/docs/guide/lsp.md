---
title: LSP
description: How Blak wires LSP — native vim.lsp.config(), no wrapper.
---

Blak is built on Neovim 0.12's native LSP API. Servers are configured with `vim.lsp.config()` and Mason-backed servers are enabled through `mason-lspconfig`'s `vim.lsp.enable()` integration. There is no `lspconfig.setup()` wrapper call anywhere in the codebase.

The native plumbing lives in [`lua/blak/plugins/lsp.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/plugins/lsp.lua). LSP keymaps are bound on `LspAttach` in [`lua/blak/core/keymaps.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/keymaps.lua).

## The flow

1. Blak collects servers from `lsp.servers` in the merged config (defaults + `user.lua` + extras).
2. For each server, it calls `vim.lsp.config(name, settings)` to register the config.
3. `mason-lspconfig` ensures Mason-backed server binaries are installed.
4. If `lsp.automatic_enable` is true (default), `mason-lspconfig` calls `vim.lsp.enable(name)` for installed Mason-backed servers.
5. When a buffer matches, Neovim auto-attaches the server and fires `LspAttach`.
6. Blak's `LspAttach` autocmd binds the buffer-local LSP keymaps.

## Default servers

Only one server ships by default — `lua_ls`, since Blak itself is Lua.

```lua
lsp = {
  servers = {
    lua_ls = {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = {
            checkThirdParty = false,
            library = vim.api.nvim_get_runtime_file("", true),
          },
          telemetry = { enable = false },
        },
      },
    },
  },
}
```

Other servers ship via [language extras](/blak.nvim/guide/extras/#languages): `ts_ls`, `eslint`, `pyright`, `ruff`, `rust_analyzer`, `taplo`, `gopls`, `marksman`.

## Adding a server

In your `user.lua`:

```lua
return {
  lsp = {
    servers = {
      zls = {
        settings = { zls = { enable_inlay_hints = true } },
      },
    },
  },
  mason = {
    ensure_installed = { "zls" }, -- if Mason knows it
  },
}
```

Or as an extra — see [Writing an extra](/blak.nvim/project/writing-extras/).

If a server is installed outside Mason and you still want it enabled automatically, register it in `user.lua` and call `vim.lsp.enable("server_name")` from a `User BlakReady` autocmd.

## Diagnostics

The default diagnostic UI:

```lua
diagnostics = {
  virtual_text = { spacing = 2, source = "if_many" },
  virtual_lines = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
}
```

Override anything you want in `user.lua`:

```lua
return {
  lsp = {
    diagnostics = {
      virtual_text = false,
      virtual_lines = true,  -- multi-line block under each diagnostic
    },
  },
}
```

## LSP keymaps

Bound on `LspAttach` so they're only available when a server is attached:

| Mapping | Action |
| --- | --- |
| `gd` | Definition |
| `gD` | Declaration |
| `gI` | Implementation |
| `gr` | References |
| `K` | Hover |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename |
| `<leader>cf` | Format |
| `<leader>cs` | Document symbols (picker) |
| `<leader>cS` | Workspace symbols (picker) |

## Disabling automatic enable

```lua
return {
  lsp = { automatic_enable = false },
}
```

Then call `vim.lsp.enable("server_name")` yourself when you want to start it.

## Inspecting what's running

```vim
:lua = vim.lsp.get_clients()       " all active clients
:lua = vim.lsp.config.lua_ls       " the config you registered
:checkhealth vim.lsp               " native health checks
```

## On Neovim nightly

Blak supports stable and nightly. Nightly changes to `vim.lsp.config()` or `vim.lsp.enable()` can cause loud errors after a Neovim upgrade. The mitigation:

1. Upgrade Neovim.
2. `:BlakUpdate` to pick up any compatibility fixes.
3. If something breaks, `:BlakRollback` and report.
