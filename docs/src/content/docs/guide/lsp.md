---
title: LSP
description: How Blak wires LSP — native vim.lsp.config(), no wrapper.
---

Blak is built on Neovim 0.12's native LSP API. Servers are configured through `vim.lsp.config` and Mason-backed servers are enabled through `mason-lspconfig`'s `vim.lsp.enable()` integration. There is no `lspconfig.setup()` wrapper call anywhere in the codebase.

The native plumbing lives in [`lua/blak/plugins/lsp.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/plugins/lsp.lua). LSP keymaps are bound on `LspAttach` in [`lua/blak/core/keymaps.lua`](https://github.com/binbandit/blak.nvim/blob/main/lua/blak/core/keymaps.lua).

## The flow

1. Blak collects servers from `lsp.servers` in the merged config (defaults + `user.lua` + extras).
2. For each server, it assigns `vim.lsp.config[name] = settings`. This replaces Blak's previous overrides on reload while retaining the server's upstream runtime defaults.
3. When `mason.automatic_install` is true, `mason-lspconfig` requests the configured Mason-backed server binaries.
4. If `lsp.automatic_enable` is true (default), `mason-lspconfig` calls `vim.lsp.enable(name)` for configured, installed Mason-backed servers.
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
          },
          telemetry = { enable = false },
        },
      },
    },
  },
}
```

Blak injects `lua_ls.settings.Lua.workspace.library` lazily when LSP setup runs, so config startup does not scan the full runtime path. Set `workspace.library` yourself if you want to replace that generated library.

Other servers ship via [language extras](/guide/extras/#languages): `ts_ls`, `tsc`, `eslint`, `pyright`, `basedpyright`, `ruff`, `rust_analyzer`, `taplo`, `gopls`, `marksman`.

For TypeScript, `lang.typescript` uses the native TypeScript 7 `tsc` language server.
Choose `lang.typescript-legacy` for the older `ts_ls` path. The former
`lang.typescript-tsgo` extra remains a compatibility alias and carries old
`tsgo` settings forward to `tsc`.
For Python, use `lang.python` for the basic Pyright path or `lang.python-pro` for BasedPyright plus Ruff's native language server.

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

Or as an extra — see [Writing an extra](/project/writing-extras/).

If a server is installed outside Mason and you still want it enabled automatically, register it in `user.lua` and call `vim.lsp.enable("server_name")` from a `User BlakReady` autocmd.

To remove a default server, use a config function, for example
`return function(config) config.lsp.servers.lua_ls = nil end`. Extras apply
afterward, so disable the corresponding extra too if it supplies that server.

Reload rebuilds server configuration for future clients. Restart Neovim when
changing settings for a language server that is already running.

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
| `<leader>cs` | Document symbols (picker) |
| `<leader>cS` | Workspace symbols (picker) |

`<leader>cf` formats through Conform in any buffer, with the configured LSP
fallback when needed. It does not require an attached language server.

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
:lsp restart                      " restart clients attached to this buffer
:lsp enable tsc                  " enable a configured server
:lsp disable tsc                 " disable it for this session
```

## On Neovim nightly

Stable Neovim 0.12+ is Blak's baseline. Nightly is a compatibility target;
changes to `vim.lsp.config()` or `vim.lsp.enable()` can cause errors after a
Neovim upgrade. The mitigation:

1. Upgrade Neovim.
2. Update the Blak Git checkout for distribution fixes and use `:BlakUpdate` for plugin updates. See [Updates](/guide/updates/).
3. If a plugin update breaks, use `:BlakRollback` and report. This does not roll back Neovim itself or the Blak checkout.
