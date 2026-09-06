#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
RUN_DIR=$(mktemp -d "${TMPDIR:-/tmp}/blak-install-smoke.XXXXXX")
RUN_DIR=$(CDPATH= cd "$RUN_DIR" && pwd -P)

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

boot() {
XDG_CONFIG_HOME="$CONFIG_HOME" \
XDG_DATA_HOME="$DATA_HOME" \
XDG_STATE_HOME="$STATE_HOME" \
XDG_CACHE_HOME="$CACHE_HOME" \
NVIM_APPNAME="$APPNAME" \
"$NVIM_BIN" --headless -u NONE \
  --cmd 'set loadplugins' \
  --cmd 'lua vim.g.blak_config={ui={splash={enabled=false}},mason={automatic_install=false,ensure_installed={}},treesitter={ensure_installed={}}}' \
  --cmd 'runtime init.lua' \
  -c 'lua if vim.g.blak_loaded ~= true then vim.api.nvim_err_writeln("Blak did not load from installed runtime checkout"); vim.cmd("cquit 1") end' \
  "$@" -c qa
}
boot

# The clone exercises the committed install. Overlay only tracked runtime files
# to check local fixes too, without copying ignored personal configuration.
git -C "$ROOT" ls-files -- init.lua lua doc lazy-lock.json NEWS.md README.md LICENSE NOTICE > "$RUN_DIR/runtime-files"
tar -C "$ROOT" -cf "$RUN_DIR/runtime.tar" -T "$RUN_DIR/runtime-files"
tar -C "$TARGET" -xf "$RUN_DIR/runtime.tar"
boot -c 'Lazy! restore'
boot

# Existing configs, launchers, and unrelated development symlinks are preserved.
if XDG_CONFIG_HOME="$CONFIG_HOME" BLAK_APPNAME="$APPNAME" BLAK_BIN_DIR="$BIN_DIR" sh "$ROOT/install.sh"; then
  echo "Installer should refuse an existing config" >&2
  exit 1
fi
for invalid in 'bad name' 'bad"name' '../escape' '-option'; do
  if BLAK_APPNAME="$invalid" sh "$ROOT/install.sh"; then
    echo "Installer accepted an unsafe app name" >&2
    exit 1
  fi
done
mkdir -p "$RUN_DIR/unrelated"
ln -s "$RUN_DIR/unrelated" "$CONFIG_HOME/dev-safety"
XDG_CONFIG_HOME="$CONFIG_HOME" BLAK_BIN_DIR="$BIN_DIR" sh "$ROOT/dev-install.sh" --appname dev-safety --uninstall
test -L "$CONFIG_HOME/dev-safety"
printf 'existing launcher\n' > "$BIN_DIR/dev-safety"
XDG_CONFIG_HOME="$CONFIG_HOME" BLAK_BIN_DIR="$BIN_DIR" sh "$ROOT/dev-install.sh" --appname dev-safety --force
test "$(cat "$BIN_DIR/dev-safety")" = 'existing launcher'

printf 'Install smoke passed: %s\n' "$TARGET"
