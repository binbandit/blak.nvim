# Validation

This checkout was validated statically in the build container with:

```sh
python3 scripts/validate.py
sh -n install.sh
grep -RIn '<legacy Black identifiers>' .
```

Result:

```text
Validation passed: 59 Lua files, 16 extras
install.sh syntax OK
stale name grep OK
```

The static validator checks:

- Lua delimiter balance after stripping strings/comments
- rough Lua keyword/end balance
- Blak-local `require()` module paths
- duplicate or missing extra IDs
- required README/help/notice/CI files
- docs-site internal `/blak.nvim/...` links
- stale `black` module, command, config, and path identifiers after the `blak.nvim` rename

Runtime validation is included:

```sh
make smoke
```

The smoke test starts Neovim headless with `NVIM_APPNAME=blak-test`, disables the splash and automatic Mason installation, loads `require("blak").setup()`, verifies config is present, runs `:checkhealth blak`, syncs plugins, runs the smoke script a second time against the synced install, exercises every public `:Blak` command, and checks directory startup.

The included GitHub Actions workflow runs static validation and a Neovim smoke test using the official stable Neovim Linux tarball.
