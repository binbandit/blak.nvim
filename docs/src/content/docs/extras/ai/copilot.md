---
title: Copilot Extra
description: Configure ai.copilot for GitHub Copilot inline suggestions through Neovim's native LSP inline completion.
---

`ai.copilot` runs GitHub's official `copilot-language-server` as a regular LSP
server and shows its suggestions with Neovim's native inline completion
(`:help lsp-inline_completion`). No Copilot plugin is involved. It is never
enabled by default.

## Enable it

```lua
-- ~/.config/blak/lua/blak/user.lua
return {
  extras = {
    enabled = {
      "ai.copilot",
    },
  },
}
```

Or enable it from Neovim:

```vim
:BlakExtras enable ai.copilot
```

Mason installs `copilot-language-server` automatically. Mason's launcher
needs Node.js 22.13 or newer on `PATH`.

## What it adds

| Surface | Contribution |
| --- | --- |
| LSP | `copilot` server (config from nvim-lspconfig) |
| Mason | `copilot-language-server` |
| Inline completion | `vim.lsp.inline_completion.enable()` |
| Commands | `:LspCopilotSignIn`, `:LspCopilotSignOut` in attached buffers |
| Keymap | `<M-l>` in insert mode accepts the suggestion |
| Keymap | `<M-]>` / `<M-[>` in insert mode cycle suggestions |

The keymaps appear in `:BlakKeys`. They do nothing when no suggestion is shown.

## Sign in

Open any file, then run:

```vim
:LspCopilotSignIn
```

The command (from nvim-lspconfig) copies a one-time code to your clipboard and
offers to open the GitHub device-login page. The server keeps credentials in
`$XDG_CONFIG_HOME/github-copilot/`, the same store copilot.lua's bundled server
uses, so an existing copilot.lua sign-in carries over. Until you sign in, the
server attaches but shows no suggestions; requests fail quietly with
`NotSignedIn` in the LSP log. `:checkhealth vim.lsp` lists the `copilot` client
and the log path.

## Configure Copilot

Server settings go through `lsp.servers.copilot`. For example, nvim-lspconfig
sends `telemetry.telemetryLevel = "all"` by default; lower it with:

```lua
return {
  extras = { enabled = { "ai.copilot" } },
  lsp = {
    servers = {
      copilot = {
        settings = { telemetry = { telemetryLevel = "off" } },
      },
    },
  },
}
```

To pause suggestions for a session:

```vim
:lua vim.lsp.inline_completion.enable(false)
```

## Next Edit Suggestions

`ai.sidekick` uses this same Copilot server for Next Edit Suggestions. Enable
both extras and set `ai.sidekick.nes.enabled = true`. See the
[Sidekick extra](/extras/ai/sidekick/).

## Disable it

```vim
:BlakExtras disable ai.copilot
```

Restart Blak to stop the server. `copilot-language-server` stays installed in
Mason until you remove it with `:Mason`.
