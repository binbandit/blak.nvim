---
title: Dev install
description: Install your checkout as a real Neovim distribution for end-to-end testing.
---

`./dev-install.sh` symlinks the working tree into `$XDG_CONFIG_HOME/<appname>` and drops a launcher in `$HOME/.local/bin`. **Edits in the checkout are live on the next launch** — no reinstall required.

It's the only way to drive Blak end-to-end before pushing.

Source: [`dev-install.sh`](https://github.com/binbandit/blak.nvim/blob/main/dev-install.sh).

## Quick start

```sh
./dev-install.sh          # symlinks repo → ~/.config/blak-dev
blak-dev                  # NVIM_APPNAME=blak-dev nvim
```

That's it. Open a buffer, `:BlakDoctor`, exercise the change.

## Flags

| Flag | Default | What |
| --- | --- | --- |
| `--appname NAME` | `blak-dev` | Use a custom `NVIM_APPNAME` (and matching launcher name). |
| `--force`, `-f` | off | Replace an existing symlink / launcher of the same name. |
| `--uninstall`, `-u` | — | Remove the symlink and launcher. Leaves runtime data dirs alone. |
| `--status`, `-s` | — | Print current install state without changing anything. |
| `--help`, `-h` | — | Show usage. |

## Environment variables

| Var | Default | Same as |
| --- | --- | --- |
| `BLAK_APPNAME` | `blak-dev` | `--appname` |
| `BLAK_BIN_DIR` | `$HOME/.local/bin` | (launcher location) |
| `XDG_CONFIG_HOME` | `$HOME/.config` | (config parent) |

## What it creates

```
$XDG_CONFIG_HOME/<appname>            symlink → this checkout
$BLAK_BIN_DIR/<appname>               launcher script (NVIM_APPNAME=<appname> exec nvim)
```

That's it on the install side. Runtime state lands under the per-appname XDG dirs as Neovim runs:

```
$XDG_DATA_HOME/<appname>/             plugins (lazy.nvim install root)
$XDG_STATE_HOME/<appname>/            extras.json + lockfile backups
$XDG_CACHE_HOME/<appname>/            caches
```

So `blak` and `blak-dev` are fully isolated — flipping back and forth doesn't poison either.

## Why a symlink

The point of dev-install is the live edit loop. Editing `lua/blak/extras/lang/zig.lua` in your IDE means the next `blak-dev` launch picks it up — no `git pull && reinstall && pray`.

The launcher script carries a small marker comment so `--status` and `--uninstall` know it's safe to operate on (vs. a manually-created launcher of the same name).

## Multiple checkouts

Want to test two branches at once? Use different appnames:

```sh
cd ~/Developer/blak.nvim
./dev-install.sh --appname blak-main
git checkout feature/zig
./dev-install.sh --appname blak-zig
blak-main      # main branch
blak-zig       # feature branch
```

Each has its own plugin install, its own extras state, its own lockfile backups.

## Uninstalling

```sh
./dev-install.sh --uninstall          # removes symlink + launcher
```

The runtime state dirs (`$XDG_DATA_HOME/blak-dev`, etc.) are intentionally **not** removed — they're expensive to rebuild and might still be useful. Delete them manually if you want a clean slate:

```sh
rm -rf ~/.local/share/blak-dev ~/.local/state/blak-dev ~/.cache/blak-dev
```

## Status

```sh
./dev-install.sh --status
```

Prints whether the symlink exists, where it points, whether the launcher exists, and whether it's the one this script created.

## When to use install.sh vs dev-install.sh

| Use | Script |
| --- | --- |
| Trying Blak from the public repo | [`install.sh`](/start/install/) |
| Hacking on Blak locally | `dev-install.sh` |
| Running CI / smoke tests | `make smoke` (or no install at all, the script sets the runtime path) |
