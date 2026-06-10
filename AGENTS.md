# Agent Instructions

This file is the single source of truth for AI coding agents working in this
repo. `CLAUDE.md` is a symlink to this file; update this file only.

## Project Overview

Blak is a native-first Neovim distribution with a strict product contract:
everything useful, nothing hidden, and preference-heavy features kept as
reversible extras.

Read these first when changing behavior or defaults:

- `README.md` for user-facing positioning and commands.
- `CONTRIBUTING.md` for design rules and repo layout.
- `MANIFESTO.md` for the product contract.
- `VALIDATION.md` for validation expectations.

## Repository Layout

- `init.lua`: repo entrypoint for Neovim.
- `lua/blak/config/`: defaults, schema, and config validation.
- `lua/blak/core/`: core options, commands, keymaps, health, update, tools,
  terminal, and autocmds.
- `lua/blak/plugins/`: default `lazy.nvim` plugin specs.
- `lua/blak/providers/`: provider adapters, especially picker adapters.
- `lua/blak/extras/`: optional modules users can enable and disable.
- `lua/blak/splash/`: black-hole splash runtime and generated frames.
- `doc/`: Vim help files.
- `docs/`: Astro Starlight documentation site.
- `scripts/`: static validation and smoke-test helpers.

## Design Rules

- Prefer native Neovim APIs before adding plugins.
- Keep defaults small, boring, memorable, and documented.
- Do not add hidden keymaps. Every keymap needs a description and should show
  up through `:BlakKeys`.
- Do not silently swap major workflow components such as picker, completion,
  explorer, or LSP strategy in stable update paths.
- Keep extras opt-in, reversible, and documented.
- Favor clear Lua modules over magic. Users should be able to inspect and
  override behavior without spelunking through indirection.

## Lua Conventions

- Follow the existing module style: local `M = {}` modules for stateful helpers,
  returned tables for plugin specs and extras.
- Keep public module APIs small and explicit.
- Use `vim.tbl_deep_extend`, `vim.validate`, and Neovim APIs where they already
  match local patterns.
- Do not introduce new dependencies unless the feature clearly earns its place
  in core or belongs in an opt-in extra.
- Preserve user configuration and state. Runtime state should live under
  Neovim state paths, not in tracked files.

## Extras

When adding an extra:

1. Create a module under `lua/blak/extras/<group>/<name>.lua`.
2. Add it to the module list in `lua/blak/extras/init.lua`.
3. Use a stable `id`, human-readable `label`, and concise `description`.
4. Declare tools, parsers, LSP, formatters, linters, keymaps, and plugins in the
   extra table rather than spreading setup across unrelated core files.
5. Update user-facing docs when the extra changes behavior or available options.

## Documentation

- Keep `README.md`, `doc/*.txt`, and `docs/src/content/docs/**` consistent when
  changing user-facing commands, options, extras, or workflows.
- Prefer direct, practical documentation over marketing copy.
- If a command or option is added, document how users discover it and how they
  undo or disable it.

## Validation

Run the narrowest useful checks for your change:

```sh
make validate
```

Run the smoke tests when touching runtime behavior and Neovim is available:

```sh
make smoke
```

Run docs checks when changing the documentation site:

```sh
make docs-build
```

The static validator does not replace headless Neovim smoke tests, but it should
pass before posting changes.

## Working Guidelines

- Keep changes focused. Do not refactor unrelated modules while fixing a narrow
  issue.
- Preserve existing user edits and generated assets unless the task explicitly
  asks to update them.
- Use `rg` for search.
- Avoid destructive git commands.
- Before editing generated-looking files, find the source or script that creates
  them.
- When behavior changes, include or update the smallest test, validation, or
  documentation path that would catch a regression.
