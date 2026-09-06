---
title: Requirements
description: What you need installed before Blak runs at full speed.
---

Blak targets **Neovim 0.12+** and is built on the native LSP API. The installer checks this version and Git before creating the checkout.

## Hard requirements

| Tool | Why |
| --- | --- |
| **Neovim 0.12+** | Native `vim.lsp.config()` and `vim.lsp.enable()` |
| **Git** | Cloning the repo and managing plugins |

## Strongly recommended

| Tool | Why |
| --- | --- |
| **ripgrep (`rg`)** | Backing grep for the picker |
| **fd** | Faster file discovery than the built-in walk |
| **tree-sitter CLI** | Build parsers locally — Blak can install this via Mason on first run |
| **A Nerd Font** | Icons in the dashboard, sidebar, and optional statusline |

Blak can start without these, but search providers may lose functionality, parser installation needs the CLI and a C compiler, and icon glyphs may appear as missing characters without a Nerd Font. Use `:BlakDoctor` to inspect the core tools.

## Optional

| Tool | When |
| --- | --- |
| **lazygit** | `:BlakExtras enable git.lazygit` |
| **node / npm** | TypeScript extras and language servers, including `lang.typescript-tsgo` |
| **rustup** | `:BlakExtras enable lang.rust` |
| **go** | `:BlakExtras enable lang.go` |
| **Claude Code CLI** | `:BlakExtras enable ai.claudecode` |
| **AI CLI tools** | `:BlakExtras enable ai.sidekick` with Codex, Claude, Gemini, OpenCode, or another Sidekick-supported CLI |

External tools required by an extra are listed in its source under `lua/blak/extras/<group>/<name>.lua`. Run `:BlakDoctor` after enabling extras — it checks core binaries and configured linters. Check the extra's documentation for other external requirements.

## Platform notes

Blak is developed on macOS and tested on Linux via the CI smoke job. It does not currently test on Windows. If you run it on Windows and find rough edges, an issue with reproduction steps is welcome.
