#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
# Resolve version-manager shims before isolating XDG paths.
NVIM_BIN=${NVIM_BIN:-$(nvim --headless --clean +'lua io.write(vim.v.progpath)' +qa 2>/dev/null)}
RUN_DIR=$(mktemp -d "${TMPDIR:-/tmp}/blak-smoke.XXXXXX")
RUN_DIR=$(CDPATH= cd "$RUN_DIR" && pwd -P)
trap 'rm -rf "$RUN_DIR"' EXIT HUP INT TERM
export XDG_CONFIG_HOME="$RUN_DIR/config"
export XDG_DATA_HOME="$RUN_DIR/share"
export XDG_STATE_HOME="$RUN_DIR/state"
export XDG_CACHE_HOME="$RUN_DIR/cache"
export NVIM_APPNAME=blak-test
export PATH="$(dirname "$NVIM_BIN"):$PATH"
cd "$ROOT"
mkdir -p "$XDG_CONFIG_HOME/$NVIM_APPNAME"
cp lazy-lock.json "$XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json"

run() {
  "$NVIM_BIN" --headless -u NONE --cmd 'set loadplugins' \
    --cmd 'lua vim.opt.rtp:prepend(vim.fn.getcwd())' "$@"
}
test_script() {
  run -c "lua dofile('scripts/run-test.lua')('$1')" -c 'qa!'
}
runtime() {
  run --cmd 'lua vim.g.blak_config={ui={splash={enabled=false}},mason={automatic_install=false},treesitter={ensure_installed={}}}' \
    --cmd 'runtime init.lua' "$@"
}

# First boot installs the committed pins. Check the installed plugins on a
# second boot; never update the tracked lockfile or reuse personal test state.
test_script scripts/smoke.lua
test_script scripts/smoke.lua
runtime -c 'lua dofile("scripts/run-test.lua")("scripts/smoke-pairs.lua")'
runtime -c 'lua vim.defer_fn(function() dofile("scripts/run-test.lua")("scripts/smoke-pickers.lua"); vim.cmd("qa!") end, 100)'
runtime -c 'lua dofile("scripts/run-test.lua")("scripts/smoke-reload.lua")' -c 'qa!'
test_script scripts/commands.lua
test_script scripts/update-contract.lua
test_script scripts/regressions.lua
runtime . -c 'lua dofile("scripts/run-test.lua")("scripts/smoke-directory.lua")' -c 'qa!'
printf 'Runtime smoke passed\n'
