---
title: Install
description: Install Blak in a single command. Side-by-side with your existing Neovim config.
---

Blak installs under its own [`NVIM_APPNAME`](https://neovim.io/doc/user/starting.html#%24NVIM_APPNAME), so it cannot overwrite an existing Neovim configuration.

## One command

```sh
curl -fsSL https://getblak.dev/install.sh | sh
blak
```

That script:

1. Verifies Git and Neovim 0.12+ are present.
2. Creates a sparse runtime checkout at `~/.config/blak`.
3. Writes a launcher at `~/.local/bin/blak` that runs `NVIM_APPNAME=blak nvim`.
4. Prints a one-line status with any caveats.

The runtime checkout includes Blak's Lua runtime, Vim help files, picker ignore metadata, lockfile, changelog, license, notice, README, and logo. It leaves out contributor-only files such as `docs/`, `scripts/`, `.github/`, and generated splash source assets.

If `~/.local/bin` is not on your `PATH`, you'll see a hint to either add it or run `NVIM_APPNAME=blak nvim` directly. An optional shell alias does the same:

```sh
alias blak='NVIM_APPNAME=blak nvim'
```

## What it creates

| Path | Purpose |
| --- | --- |
| `~/.config/blak/` | Sparse runtime checkout |
| `~/.local/bin/blak` | Launcher that sets `NVIM_APPNAME=blak` |
| `~/.local/share/blak/` | Plugin data (lazy.nvim) |
| `~/.local/state/blak/` | State including the extras file |

Nothing under `~/.config/nvim/` is touched.

## Customizing the install location

The installer respects environment variables when you want isolation for testing or multiple checkouts.

```sh
# Install under a different app name (e.g. blak-dev)
curl -fsSL https://getblak.dev/install.sh | BLAK_APPNAME=blak-dev sh

# Install from a fork
curl -fsSL https://getblak.dev/install.sh | \
  BLAK_REPO_URL=https://github.com/your-fork/blak.nvim.git sh

# Install a specific branch or tag from that repo
curl -fsSL https://getblak.dev/install.sh | BLAK_REF=feature-branch sh
```

When `BLAK_APPNAME` is set, the config directory and launcher both use that name. For example, `BLAK_APPNAME=blak-dev` creates `~/.config/blak-dev/` and `~/.local/bin/blak-dev`.

## From a clone (developers)

If you want to hack on Blak itself, clone first and symlink:

```sh
git clone https://github.com/binbandit/blak.nvim ~/Developer/blak.nvim
cd ~/Developer/blak.nvim
./dev-install.sh
blak-dev
```

This symlinks the checkout to `~/.config/blak-dev`. Edits in the checkout are live on next launch, with plugin state fully isolated from a production `blak` install. See [Contributing](/contributing/) for the full dev loop.

## Uninstalling

```sh
rm -rf ~/.config/blak ~/.local/share/blak ~/.local/state/blak ~/.local/bin/blak
```

That's it — no system files were touched.
