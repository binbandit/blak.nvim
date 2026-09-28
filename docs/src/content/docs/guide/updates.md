---
title: Updates & rollback
description: How Blak handles updates so a bad commit upstream never strands you.
---

The contract: **stable updates must not silently swap a major workflow component, and a bad lockfile or config migration must never be a one-way trip.** Blak enforces this with three commands, rollback snapshots, and explicit upgrade migrations.

## The commands

### `:BlakUpdate`

1. Checks that `package.channel` has not changed since the last accepted update or upgrade.
2. Checks for pending breaking migrations.
3. Snapshots `lazy-lock.json`, `lua/blak/user.lua`, `extras.json`, migration state, and update state to `stdpath('state')/blak/rollbacks/`.
4. Runs `:Lazy update`.

The snapshot happens *before* the update, so if `:Lazy update` itself fails, you still have the original lockfile and config state.

### `:BlakRollback`

1. Finds the most recent rollback snapshot.
2. Restores the lockfile and config state that existed before the update or upgrade.
3. Reloads Blak config and runs `:Lazy restore`.

The lockfile pins and tracked config state are restored. Lazy then checks out the pinned plugin commits. Network access may be needed for missing repositories, commits, or build artifacts; external tools and plugin-managed data are not included.

## The convention

Stable updates are conservative. They do not:

- Swap your default picker.
- Swap your completion engine.
- Swap your LSP wiring strategy.
- Change `<leader>` or `<localleader>`.

Changes to those defaults require an explicit migration and release note; optional alternatives live in extras. A `package.channel` change is also treated as an upgrade-only move. See `package.channel` in [the schema](/reference/schema/).

For intentional bigger moves there's a separate command:

### `:BlakUpgrade`

For things like switching channels (`stable` → `edge`), major-version bumps, or migrations that *are* allowed to swap workflow components. `:BlakUpgrade` snapshots first, applies pending migrations, records the current channel as accepted, then runs `:Lazy update`. The split exists so that you can run `:BlakUpdate` without thinking, and run `:BlakUpgrade` deliberately.

## A typical update flow

```vim
:BlakUpdate           " snapshot + channel-safe update
" something feels off ↓
:BlakDoctor           " confirm what broke
:BlakRollback         " restore the previous set
```

If you want the update but a single plugin regressed:

```vim
:BlakRollback         " restore everything
:Lazy update foo.nvim " update just the one
```

## Snapshot retention

Snapshots accumulate in `stdpath('state')/blak/rollbacks/`. Blak doesn't auto-prune them because they are cheap and the safety they provide is high. If they bother you, deleting old ones by hand is fine; `:BlakRollback` always uses the newest. Legacy lockfile-only backups in `stdpath('state')/blak/lockbacks/` are still readable.

## On nightly Neovim

Supported stable Neovim releases are the baseline. CI requires the stable smoke
and installer checks and runs an advisory nightly smoke job. Nightly remains a
compatibility target; upstream API changes can still cause errors. If one does:

1. Upgrade Neovim.
2. Update the Blak checkout as described below, then run `:BlakUpdate` for plugin fixes.
3. Use `:BlakRollback` for a plugin regression and report the issue. For a Neovim
   regression, return to a supported stable Neovim release; Blak's snapshots
   do not contain the editor executable.

## Updating Blak itself

`:BlakUpdate` and `:BlakUpgrade` update plugins; they do not fetch this distribution's Git checkout. Review `NEWS.md`, preserve your local changes, then update the checkout explicitly:

```sh
git -C ~/.config/blak pull --ff-only
```

Use your actual XDG config path if different. If Git reports local changes or divergent history, resolve those before proceeding. Restart Blak and run `:BlakUpgrade` for pending migrations. Rollback snapshots do not include the distribution's Git revision.

Checkout changes take effect on the next startup; `:BlakUpgrade` is not a gate
on loading manually updated source. For the native TypeScript transition,
review the release note before updating. If you want to retain `ts_ls`, replace
`lang.typescript` or `lang.typescript-tsgo` with `lang.typescript-legacy` as part
of that checkout upgrade, before restarting. Otherwise the standard extra uses
`tsc`; remove any explicit `lsp.servers.ts_ls` entry to avoid starting both.
Run `:BlakToolsInstall`, wait for completion, and restart after upgrading.

`package.channel` currently selects Blink's version policy: `stable` uses `1.*`; `edge` and `nightly` both build the development branch with Cargo. Other plugins follow their configured branches. These are not separate Blak release branches, and upstream plugin updates can still introduce breaking changes. Direct `:Lazy` commands bypass Blak's channel/migration checks.
