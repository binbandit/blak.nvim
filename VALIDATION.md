# Validation

Run these checks from the repository root:

```sh
make validate
make smoke
make smoke-install
make docs-build
```

`make validate` uses Python for structural Lua checks, local require paths,
extra IDs, plugin loading rules, documented defaults, required files, and docs
links. It syntax-checks the installers and smoke runners. The Python checks
are heuristics, not a Lua parser or proof of runtime correctness.

`make smoke` requires Neovim 0.12+ and network access for plugin installation.
It creates temporary XDG config, data, state, and cache directories, copies the
committed lockfile, and tests this working tree against those pins. It does not
modify the checkout's lockfile or existing user/test state. `NVIM_BIN` can
select a particular Neovim executable.

The suite checks first and subsequent startup, configuration and reload,
keymaps, completion pairs, real fff file/grep and Snacks picker UI, splash
rendering, every public command, extras state, update/upgrade/rollback contracts, directory startup, and focused
regressions, including real Conform/Blink option reload and native helper
availability. Every shipped Lua module is syntax-compiled; each extra is built
and validated independently. Lua assertion failures exit nonzero.

Command tests use controlled substitutes for network updates, picker dispatch,
and some tool/plugin operations. Health output is diagnostic; a warning is not
by itself a failed test. Passing smoke does not verify every external language
server, debugger adapter, AI account, terminal image protocol, or combination
of extras. Exercise the specific language/project or external service when
changing its integration. A restart is required to verify extras unloading.

`make smoke-install` runs the installer in temporary XDG directories, checks
the sparse checkout, boots it, then overlays tracked runtime files from the
working tree and boots again. This checks both the committed install and local
runtime changes. It also tests installer refusal to overwrite existing paths.

`make docs-build` requires Node.js 22.12+ and installed docs dependencies
(`make docs-install`). CI uses Node.js 24. It builds all documentation routes,
search indexes, and generated install/social assets. Preview the site when
changing its layout or upgrading Astro/Starlight.

GitHub Actions runs static, runtime, and installer checks on pushes to main and
pull requests. The docs workflow builds for docs/installer/workflow changes
and deploys successful main builds to GitHub Pages. Local checks help catch
regressions; CI also depends on its OS, network, and upstream services.
