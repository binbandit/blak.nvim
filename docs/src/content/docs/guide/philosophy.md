---
title: Philosophy
description: The six rules that decide what lands in core, what lives in an extra, and what doesn't ship at all.
---

Blak is optimized for **maintainability first**. A feature belongs in core only if most users benefit from it. Everything else should be an extra.

## The manifesto

Blak is not here to turn Neovim into VS Code.

Blak is here to make Neovim feel inevitable.

We use native Neovim first.

We ship only what earns its gravity.

We do not hide configuration behind magic.

We do not break your muscle memory on update.

We make extras easy, reversible, and documented.

## The six rules

### 1. Prefer native Neovim APIs before adding plugins.

Neovim 0.12 ships with native LSP configuration, completion sources, diagnostics, snippet support, and tree-sitter helpers. Reach for those first. A plugin should earn its place by adding capability that the native API doesn't have, not by being more familiar.

### 2. Keep defaults boring, memorable, and documented.

The rule of thumb: a user should be able to predict a keymap from the category and the action. `<leader>f` for find, `<leader>g` for git, `<leader>c` for code. No clever overloading, no chords that require a cheat sheet to remember.

### 3. Do not add hidden keymaps.

Every keymap registered by Blak core, an enabled extra, or `user.lua` has a description and appears in `:BlakKeys`. If you can't see it there, it doesn't exist in Blak. Plugins that add their own un-described mappings are wrapped to give them descriptions.

### 4. Stable updates must not silently change a user's picker, completion engine, explorer, or LSP strategy.

These are the things that show up in muscle memory. Changing them out from under a user costs more than the new tool's improvements buy back. If a change to one of these is right, it lands behind `:BlakUpgrade` or an extra, not in a stable `:BlakUpdate`.

### 5. Extras must be reversible.

Every Treesitter parser, Mason tool, LSP server, formatter, linter, Snacks module, keymap, and plugin spec contributed by an extra is rolled back when the extra is disabled. No orphans.

### 6. If a smart simple solution solves the problem without compromise, use it.

The temptation in Neovim distros is to abstract everything — picker layers, plugin spec wrappers, settings DSLs. Blak resists. Where a five-line table works, a five-line table ships.

## What this means in practice

### Reading the source

`lua/blak/config/defaults.lua` is the canonical answer to "what are the defaults?" It is not generated, summarized, or DSL'd. You can read it in two minutes.

```text
lua/blak/config/     defaults and validation
lua/blak/core/       options, commands, keymaps, health, update, tools
lua/blak/plugins/    base lazy.nvim specs
lua/blak/providers/  adapters for picker/package features
lua/blak/extras/     optional modules
lua/blak/splash/     black-hole animation
```

If you can find a directory in that list, you can find the thing inside it.

### Naming

Things are named by what they are, not how they're spelled in a competitor's docs. The completion engine is `blink.cmp`, not "completion". The picker dispatch lives in `lua/blak/providers/picker.lua` and is named `picker`.

### Defaults vs. configuration

Blak's defaults are opinionated and small. Configuration is one file (`user.lua`) and one command (`:BlakExtras`). Anything you can do in `user.lua` you can also do by editing the defaults directly if you fork — but most users don't need to.

### Stability over novelty

If a new plugin solves a problem 5% better than a current one but breaks muscle memory, the current one stays. The rule is not "ship the best plugin" — it's "ship the plugin that the next million minutes of typing will be cheaper with."

## The name

Blak is short for *black hole*. The name is the promise: a black hole pulls in everything useful for editing code, and lets nothing escape back out as noise.

> Everything useful. Nothing escapes.
