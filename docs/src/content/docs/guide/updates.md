---
title: Updates & rollback
description: How Blak handles updates so a bad commit upstream never strands you.
---

The contract: **stable updates must not silently swap a major workflow component, and a bad lockfile must never be a one-way trip.** Blak enforces this with two commands and one convention.

## The two commands

### `:BlakUpdate`

1. Reads the current `lazy-lock.json`.
2. Writes a timestamped backup to `stdpath('state')/blak/lockbacks/`.
3. Runs `:Lazy update`.

The backup happens *before* the update, so if `:Lazy update` itself fails, you still have the original lockfile.

### `:BlakRollback`

1. Finds the most recent backup in the lockfile backup directory.
2. Restores it as `lazy-lock.json`.
3. Runs `:Lazy restore`.

Result: every plugin returns to the exact commit it was at before the last `:BlakUpdate`. Even with no network, this works.

## The convention

Stable updates are conservative. They do not:

- Swap your default picker.
- Swap your completion engine.
- Swap your LSP wiring strategy.
- Change `<leader>` or `<localleader>`.

If a change requires any of those, it lands on the **edge** channel (or behind an extra) until enough adopters have validated it. See `package.channel` in [the schema](/blak.nvim/reference/schema/).

For intentional bigger moves there's a separate command:

### `:BlakUpgrade`

For things like switching channels (`stable` → `edge`) or major-version bumps that *are* allowed to swap workflow components. The split exists so that you can run `:BlakUpdate` without thinking, and run `:BlakUpgrade` deliberately.

## A typical update flow

```vim
:BlakUpdate           " snapshot + update
" something feels off ↓
:BlakDoctor           " confirm what broke
:BlakRollback         " restore the previous set
```

If you want the update but a single plugin regressed:

```vim
:BlakRollback         " restore everything
:Lazy update foo.nvim " update just the one
```

## Backup retention

Backups accumulate in `stdpath('state')/blak/lockbacks/`. Blak doesn't auto-prune them — they're cheap (a few KB each) and the safety they provide is high. If they bother you, deleting old ones by hand is fine; `:BlakRollback` always uses the newest.

## On nightly Neovim

Blak supports Neovim stable and nightly. Nightly changes to `vim.lsp.config()` or other native APIs can cause loud errors after a Neovim upgrade. The mitigation:

1. Upgrade Neovim.
2. `:BlakUpdate` to pick up any compatibility fixes shipped here.
3. If something breaks, `:BlakRollback` and report — Blak's CI runs against stable and can lag nightly by a day or two.
