---
title: Contributing
description: How to propose a change, run the validation pipeline, and ship something useful.
---

Blak is optimized for **maintainability first**. A feature belongs in core only if most users benefit from it. Everything else should be an extra.

## Design rules

1. Prefer native Neovim APIs before adding plugins.
2. Keep defaults boring, memorable, and documented.
3. Do not add hidden keymaps. Every keymap needs a description and should appear in `:BlakKeys`.
4. Stable updates must not silently change a user's picker, completion engine, explorer, or LSP strategy.
5. Extras must be reversible.
6. If a smart simple solution solves the problem without compromise, use it.

See [Philosophy](/guide/philosophy/) for the reasoning behind these.

## Pick the right track

| Track | When |
| --- | --- |
| **Core change** | Affects most users (defaults, commands, keymaps, options). |
| **New extra** | Optional capability for some users → see [Writing an extra](/project/writing-extras/). |
| **Bug fix** | Open a PR directly with a reproduction. |
| **Docs only** | Open a PR directly. |
| **New provider** (picker, package backend) | Open an issue first to align on the interface. |

For non-trivial changes, **open an issue first** describing the problem you're solving. The maintainers will tell you which track fits.

## Dev loop

```sh
git clone https://github.com/binbandit/blak.nvim ~/Developer/blak.nvim
cd ~/Developer/blak.nvim
./dev-install.sh                                  # symlinks → ~/.config/blak-dev
blak-dev                                          # launches NVIM_APPNAME=blak-dev
```

Edits in the checkout are live on next launch. Plugin state and lockfile backups live under `~/.local/{share,state}/blak-dev/` — fully isolated from any production `blak` install. Full options in [Dev install](/project/dev-install/).

## Validate before you push

```sh
make validate            # static checks, no Neovim required (< 100 ms)
make smoke               # headless Neovim + Lazy sync + checkhealth
```

Both run in CI on every push and pull request. Details in [Validation & CI](/project/validation/).

Run `stylua --check .` locally once Stylua is installed — CI will gate on it soon.

## Code style

- StyLua for formatting (`stylua .`).
- Two-space indent.
- No top-level side effects in `require()` graphs — every module is `local M = {}` returning a table.
- Errors use `error()` with a descriptive message. User-facing notifications go through `require("blak.util").notify`.
- Comments only when the *why* isn't obvious from the code.

## Documentation

The site you're reading lives under `docs/` and is built with Astro Starlight.

```sh
make docs-install        # cd docs && npm install
make docs-dev            # http://localhost:4321/
make docs-build          # produces docs/dist/ for GitHub Pages
```

Auto-deploys to [getblak.dev](https://getblak.dev/) on every push to `main` via [`.github/workflows/docs.yml`](https://github.com/binbandit/blak.nvim/blob/main/.github/workflows/docs.yml).

When you add a feature, update the relevant page so the site stays the source of truth. New file? Add it to the sidebar in `docs/astro.config.mjs`.

## License

Blak is MIT-licensed. By contributing, you agree your changes will ship under the same license.
