---
title: Validation & CI
description: Static validation, the headless smoke test, and the Makefile targets that wrap them.
---

Blak has two safety nets every contributor runs locally and CI runs on every push:

- **Static validation** — no Neovim required, runs in seconds.
- **Smoke test** — boots Neovim headless and asserts setup works end to end.

## `make validate`

Runs [`scripts/validate.py`](https://github.com/binbandit/blak.nvim/blob/main/scripts/validate.py).

### What it checks

| Check | Why |
| --- | --- |
| Lua syntax: balanced delimiters | Catch `{` without `}`, etc., in 0 ms — no Lua runtime required. |
| Lua syntax: keyword nesting | `if` / `function` / `for` / `while` / `repeat` close with `end` (or `until` for `repeat`). |
| Require paths | Every `require("blak.…")` resolves to an actual file. |
| Unique extra IDs | No two files under `lua/blak/extras/` declare the same `id`. |
| Splash frame structure | Frame count and color count match. Each frame is 14 rows of 50 braille glyphs. Color spans are well-formed. |
| Required docs | `README.md`, `CONTRIBUTING.md`, `NOTICE`, `doc/blak.txt`, `doc/blak-extras.txt`, `doc/blak-keymaps.txt`, `.github/workflows/ci.yml` exist. |
| Legacy identifier cleanup | No leftover `"black"` references from the early-naming migration. |

### Output

```
Validation passed: 54 Lua files, 15 extras
```

On failure, every problem is reported in one pass — fix them in a batch rather than running validate → fix → run → fix.

### When to run

- Before committing.
- Before opening a PR.
- In a tight loop while refactoring (it's milliseconds).

## `make smoke`

Runs Neovim headless against this checkout four times:

1. First invocation: sets the runtime path, runs `:Lazy! sync` to install plugins, then quits.
2. Second invocation: cold-boot test — sets the runtime path, executes [`scripts/smoke.lua`](https://github.com/binbandit/blak.nvim/blob/main/scripts/smoke.lua), then quits.
3. Third invocation: command-contract test — executes [`scripts/commands.lua`](https://github.com/binbandit/blak.nvim/blob/main/scripts/commands.lua), exercises every public `:Blak` command, stubs destructive Lazy actions, verifies extras state changes, and confirms command completion.
4. Fourth invocation: starts with `.` as the directory argument and checks [`scripts/smoke-directory.lua`](https://github.com/binbandit/blak.nvim/blob/main/scripts/smoke-directory.lua), so `blak .` cannot regress to an empty buffer.

### What smoke.lua does

```lua
vim.g.blak_config = {
  ui = { splash = { enabled = false } },
  mason = { automatic_install = false },
}
require("blak").setup()
assert(require("blak.config").get() ~= nil, "config missing")
assert(vim.fn.exists(":Lazy") == 2, ":Lazy missing")
assert(vim.fn.exists(":BlakTerminal") == 2, ":BlakTerminal missing")
assert(vim.fn.maparg("<leader>/", "n", false, true).desc == "Grep")
assert(vim.fn.maparg("<leader>tt", "n", false, true).desc == "Terminal")
assert(vim.fn.maparg("-", "n") == "")
local lazy_plugins = require("lazy.core.config").plugins
assert(lazy_plugins["oil.nvim"].lazy == false)
assert(lazy_plugins["oil.nvim"].opts.default_file_explorer == true)
vim.cmd("checkhealth blak")
```

Translation:

- Disable the splash and Mason auto-install (both noisy in headless).
- Run setup. Any validation error or runtime error fails the test.
- Confirm the merged config exists.
- Confirm lazy.nvim's `:Lazy` command is registered.
- Confirm Blak's terminal command and core keymaps are registered.
- Confirm Oil is eager and owns directory buffers.
- Run `:checkhealth blak` — any error or warning in the health module shows up in output.

### What commands.lua does

The command-contract smoke test asserts every documented `:Blak*` command exists and can be invoked. It exercises overview, health, keys, news, picker dispatch, extras list/enable/disable/sync, update/upgrade/rollback backup wiring, tool/parser install no-op paths, formatting, format toggles, terminal, and splash preview.

It stubs Lazy's update/sync/restore commands so CI checks Blak's command behavior without doing network updates in the middle of the test.

### Smoke needs Neovim 0.12+

```sh
make smoke
```

Uses `NVIM_APPNAME=blak-test` (configurable: `SMOKE_NVIM_APPNAME=foo make smoke`). The state dir is at `$XDG_DATA_HOME/blak-test/` — feel free to wipe between runs.

## CI

[`.github/workflows/ci.yml`](https://github.com/binbandit/blak.nvim/blob/main/.github/workflows/ci.yml) runs both targets on every push and PR.

| Job | Runner | Step |
| --- | --- | --- |
| `validate` | `ubuntu-latest` | Run `python3 scripts/validate.py` |
| `smoke` | `ubuntu-latest` | Install Neovim stable, run `make smoke` |

[`.github/workflows/docs.yml`](https://github.com/binbandit/blak.nvim/blob/main/.github/workflows/docs.yml) builds and deploys this documentation site to [getblak.dev](https://getblak.dev/) via GitHub Pages on every push to `main`.

## Makefile reference

```makefile
make validate              # python3 scripts/validate.py
make smoke                 # headless Neovim + Lazy sync + checkhealth
make docs                  # alias for docs-dev
make docs-install          # cd docs && npm install
make docs-dev              # cd docs && npm run dev (http://localhost:4321/)
make docs-build            # cd docs && npm run build
make zip                   # zip the repo for distribution (excludes git, node_modules, dist)
```

## Pre-commit checklist

```sh
make validate              # < 100 ms
make smoke                 # ~10 s (longer on cold lazy cache)
stylua --check .           # when stylua is installed; CI enforces it eventually
```

If all three pass locally, CI will pass.
