#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
RUN_DIR=$(mktemp -d "${TMPDIR:-/tmp}/blak-install-smoke.XXXXXX")

cleanup() {
  rm -rf "$RUN_DIR"
}
trap cleanup EXIT HUP INT TERM

CONFIG_HOME="$RUN_DIR/config"
DATA_HOME="$RUN_DIR/share"
STATE_HOME="$RUN_DIR/state"
CACHE_HOME="$RUN_DIR/cache"
BIN_DIR="$RUN_DIR/bin"
APPNAME="blak-install-smoke"
TARGET="$CONFIG_HOME/$APPNAME"

mkdir -p "$CONFIG_HOME" "$DATA_HOME" "$STATE_HOME" "$CACHE_HOME" "$BIN_DIR"

# Resolve through version-manager shims before the test rewrites XDG paths and
# NVIM_APPNAME; some shims keep trust/config state outside the temp dirs.
NVIM_BIN="${NVIM_BIN:-}"
if [ -z "$NVIM_BIN" ]; then
  NVIM_BIN=$(nvim --headless --clean +'lua io.write(vim.v.progpath)' +qa 2>/dev/null || command -v nvim)
fi
PATH="$(dirname "$NVIM_BIN"):$PATH"
export PATH

XDG_CONFIG_HOME="$CONFIG_HOME" \
BLAK_APPNAME="$APPNAME" \
BLAK_REPO_URL="$ROOT" \
BLAK_BIN_DIR="$BIN_DIR" \
sh "$ROOT/install.sh"

test -f "$TARGET/.gitignore"
test -f "$TARGET/.ignore"
test -f "$TARGET/init.lua"
test -d "$TARGET/lua/blak"
test -d "$TARGET/doc"
test -f "$TARGET/lazy-lock.json"
test -f "$TARGET/NEWS.md"
test -f "$TARGET/README.md"
test -f "$TARGET/LICENSE"
test -f "$TARGET/NOTICE"
test -f "$TARGET/assets/blak-ascii.svg"
test ! -e "$TARGET/assets/blackhole.gif"
test ! -e "$TARGET/docs"
test ! -e "$TARGET/scripts"
test ! -e "$TARGET/.github"

XDG_CONFIG_HOME="$CONFIG_HOME" \
XDG_DATA_HOME="$DATA_HOME" \
XDG_STATE_HOME="$STATE_HOME" \
XDG_CACHE_HOME="$CACHE_HOME" \
NVIM_APPNAME="$APPNAME" \
"$NVIM_BIN" --headless -u NONE \
  --cmd 'set loadplugins' \
  --cmd 'lua vim.g.blak_config={ui={splash={enabled=false}},mason={automatic_install=false,ensure_installed={}},treesitter={ensure_installed={}}}' \
  --cmd 'runtime init.lua' \
  -c 'lua assert(vim.g.blak_loaded == true, "Blak did not load from installed runtime checkout")' \
  -c qa

printf 'Install smoke passed: %s\n' "$TARGET"
