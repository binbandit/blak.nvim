# Validation

This checkout was validated statically in the build container with:

```sh
python3 scripts/validate.py
sh -n install.sh
sh -n scripts/smoke-install.sh
grep -RIn '<legacy Black identifiers>' .
```

Result:

```text
Validation passed: 85 Lua files, 36 extras
install.sh syntax OK
scripts/smoke-install.sh syntax OK
stale name grep OK
```

The static validator checks:

- Lua delimiter balance after stripping strings/comments
- rough Lua keyword/end balance
- Blak-local `require()` module paths
- duplicate or missing extra IDs
- default and extra plugin specs have a lazy-loading trigger, explicit on-demand loading, or an approved eager-startup reason
- required README/help/notice/CI files
- docs-site internal `/blak.nvim/...` links
- stale `black` module, command, config, and path identifiers after the `blak.nvim` rename

Runtime validation is included:

```sh
make smoke
make smoke-install
```

The smoke test starts Neovim headless with `NVIM_APPNAME=blak-test`, disables the splash and automatic Mason installation, loads `require("blak").setup()`, verifies config is present, checks config merging avoids full runtime-path scans, runs `:checkhealth blak`, syncs plugins, runs the smoke script a second time against the synced install, exercises every public `:Blak` command, and checks directory startup.

The install smoke test runs the public installer into temporary XDG directories, verifies the sparse runtime checkout omits contributor-only directories, and boots that installed checkout headlessly.

The included GitHub Actions workflow runs static validation, the Neovim smoke test, and the installer smoke test using the official stable Neovim Linux tarball.
