#!/usr/bin/env sh
# Refresh lazy-lock.json, Blak's shipped pins, to the newest commit (within
# each spec's version constraint) of every plugin that core or an extra can
# install. Run it before a release, then run `make smoke` and review the diff.
#
# Everything runs in temporary XDG directories: the checkout's lazy-lock.json
# is the only file this changes. editor.mini modules are chosen by the user, so
# they cannot be pinned ahead of time and follow their default branch.
set -eu

ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
NVIM_BIN=${NVIM_BIN:-$(nvim --headless --clean +'lua io.write(vim.v.progpath)' +qa 2>/dev/null)}
RUN_DIR=$(mktemp -d "${TMPDIR:-/tmp}/blak-pins.XXXXXX")
trap 'rm -rf "$RUN_DIR"' EXIT HUP INT TERM
export XDG_CONFIG_HOME="$RUN_DIR/config"
export XDG_DATA_HOME="$RUN_DIR/share"
export XDG_STATE_HOME="$RUN_DIR/state"
export XDG_CACHE_HOME="$RUN_DIR/cache"
export NVIM_APPNAME=blak-pins

# Boot a copy of the working tree, the way an install would.
CONFIG="$XDG_CONFIG_HOME/$NVIM_APPNAME"
mkdir -p "$CONFIG"
git -C "$ROOT" ls-files --cached --others --exclude-standard -- init.lua lua lazy-lock.json \
  | while IFS= read -r file; do [ -e "$ROOT/$file" ] && printf '%s\n' "$file"; done \
  | (cd "$ROOT" && tar -cf - -T -) | tar -C "$CONFIG" -xf -

blak() {
  "$NVIM_BIN" --headless \
    --cmd 'lua vim.g.blak_config={ui={splash={enabled=false}},mason={automatic_install=false},treesitter={ensure_installed={}}}' \
    "$@" +qa
}

# Enable every extra so all plugin specs, including the ones that only apply
# when two extras are combined, take part in the sync.
blak +'lua require("blak.extras.state").write(vim.tbl_map(function(extra) return extra.id end, require("blak.extras").all()))'
blak +'Lazy! sync'

cp "$XDG_STATE_HOME/$NVIM_APPNAME/blak/lazy-lock.json" "$ROOT/lazy-lock.json"
printf 'Updated %s. Run make smoke, then review the diff.\n' "$ROOT/lazy-lock.json"
