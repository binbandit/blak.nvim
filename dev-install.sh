#!/usr/bin/env sh
# dev-install.sh — install this checkout of blak.nvim as a Neovim distribution
# so local changes can be exercised end-to-end before pushing.
#
# By default this symlinks the working tree to $XDG_CONFIG_HOME/blak-dev and
# drops a `blak-dev` launcher in $HOME/.local/bin. Edits in the checkout are
# picked up the next time you launch Neovim — no reinstall required.
#
# Usage:
#   ./dev-install.sh                 install (symlink) under appname "blak-dev"
#   ./dev-install.sh --appname NAME  use a different NVIM_APPNAME
#   ./dev-install.sh --force         replace an existing symlink/launcher
#   ./dev-install.sh --uninstall     remove the symlink and launcher
#   ./dev-install.sh --status        show what is currently installed
#   ./dev-install.sh --help          show this help
#
# Environment overrides:
#   BLAK_APPNAME      same as --appname
#   BLAK_BIN_DIR      launcher directory (default: $HOME/.local/bin)
#   XDG_CONFIG_HOME   config parent      (default: $HOME/.config)

set -eu

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd -P)
REPO_ROOT=$SCRIPT_DIR

APPNAME=${BLAK_APPNAME:-blak-dev}
CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
BIN_DIR=${BLAK_BIN_DIR:-$HOME/.local/bin}
ACTION=install
FORCE=0

LAUNCHER_MARKER="# blak.nvim dev-install.sh launcher"

usage() {
  cat <<USAGE
Usage: $0 [options]

Install this checkout of blak.nvim for development testing. Symlinks the
working tree to \$XDG_CONFIG_HOME/<appname> and creates a launcher at
\$BLAK_BIN_DIR/<appname> so changes are visible without reinstalling.

Options:
  --appname NAME    NVIM_APPNAME to install under (default: blak-dev)
  --force, -f       Replace an existing symlink or launcher created by this script
  --uninstall, -u   Remove the symlink and launcher for the given appname
  --status, -s      Show what is currently installed for the given appname
  --help, -h        Show this help

Environment:
  BLAK_APPNAME      same as --appname
  BLAK_BIN_DIR      launcher directory (default: \$HOME/.local/bin)
  XDG_CONFIG_HOME   config parent      (default: \$HOME/.config)
USAGE
}

die() { echo "$*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "$1 is required"
}

resolve_symlink() {
  # `readlink <path>` (one level) works on both BSD and GNU.
  readlink -- "$1" 2>/dev/null || true
}

is_managed_launcher() {
  [ -f "$1" ] && head -n 5 -- "$1" 2>/dev/null | grep -Fq "$LAUNCHER_MARKER"
}

while [ $# -gt 0 ]; do
  case $1 in
    --appname)
      [ $# -ge 2 ] || die "--appname requires a value"
      APPNAME=$2
      shift 2
      ;;
    --appname=*)
      APPNAME=${1#--appname=}
      shift
      ;;
    --force|-f) FORCE=1; shift ;;
    --uninstall|-u) ACTION=uninstall; shift ;;
    --status|-s) ACTION=status; shift ;;
    --help|-h) usage; exit 0 ;;
    --) shift; break ;;
    -*) usage >&2; die "Unknown option: $1" ;;
    *) usage >&2; die "Unexpected argument: $1" ;;
  esac
done

case $APPNAME in
  ""|*/*|.|..) die "Invalid --appname: '$APPNAME'" ;;
esac

TARGET=$CONFIG_HOME/$APPNAME
LAUNCHER=$BIN_DIR/$APPNAME

print_status() {
  echo "App name:    $APPNAME"
  echo "Repo root:   $REPO_ROOT"
  echo "Target dir:  $TARGET"
  if [ -L "$TARGET" ]; then
    echo "  -> $(resolve_symlink "$TARGET") (symlink)"
  elif [ -e "$TARGET" ]; then
    echo "  (exists but is NOT a symlink — left untouched)"
  else
    echo "  (not installed)"
  fi
  echo "Launcher:    $LAUNCHER"
  if is_managed_launcher "$LAUNCHER"; then
    echo "  (installed by this script)"
  elif [ -e "$LAUNCHER" ]; then
    echo "  (exists but was not created by this script — left untouched)"
  else
    echo "  (not installed)"
  fi
}

install_symlink() {
  if [ -L "$TARGET" ]; then
    current=$(resolve_symlink "$TARGET")
    if [ "$current" = "$REPO_ROOT" ]; then
      echo "Symlink already points at $REPO_ROOT."
      return
    fi
    if [ $FORCE -eq 1 ]; then
      rm -- "$TARGET"
      ln -s -- "$REPO_ROOT" "$TARGET"
      echo "Replaced symlink: $TARGET -> $REPO_ROOT (was -> $current)"
      return
    fi
    die "$TARGET is a symlink to $current.
Re-run with --force to repoint it, or use --appname to pick a different name."
  fi

  if [ -e "$TARGET" ]; then
    die "$TARGET exists and is not a symlink.
Refusing to touch a real directory — it may be your day-to-day Neovim config.
Move it aside, or re-run with --appname to install under a different name."
  fi

  mkdir -p -- "$CONFIG_HOME"
  ln -s -- "$REPO_ROOT" "$TARGET"
  echo "Symlinked: $TARGET -> $REPO_ROOT"
}

install_launcher() {
  if ! mkdir -p -- "$BIN_DIR" 2>/dev/null; then
    echo "Could not create $BIN_DIR; skipping launcher." >&2
    echo "Start Neovim manually with: NVIM_APPNAME=$APPNAME nvim" >&2
    return
  fi

  if [ -e "$LAUNCHER" ] && ! is_managed_launcher "$LAUNCHER" && [ $FORCE -eq 0 ]; then
    echo "$LAUNCHER already exists and was not created by this script." >&2
    echo "Re-run with --force to overwrite, or start Neovim manually:" >&2
    echo "  NVIM_APPNAME=$APPNAME nvim" >&2
    return
  fi

  cat > "$LAUNCHER" <<LAUNCHER
#!/usr/bin/env sh
$LAUNCHER_MARKER
# appname: $APPNAME
# source:  $REPO_ROOT
NVIM_APPNAME="$APPNAME" exec nvim "\$@"
LAUNCHER
  chmod +x "$LAUNCHER"
  echo "Launcher:  $LAUNCHER"
}

uninstall() {
  removed=0

  if [ -L "$TARGET" ]; then
    current=$(resolve_symlink "$TARGET")
    rm -- "$TARGET"
    echo "Removed symlink: $TARGET (was -> $current)"
    removed=1
  elif [ -e "$TARGET" ]; then
    echo "$TARGET exists but is not a symlink; leaving it in place." >&2
  fi

  if is_managed_launcher "$LAUNCHER"; then
    rm -- "$LAUNCHER"
    echo "Removed launcher: $LAUNCHER"
    removed=1
  elif [ -e "$LAUNCHER" ]; then
    echo "$LAUNCHER exists but was not created by this script; leaving it in place." >&2
  fi

  if [ $removed -eq 0 ]; then
    echo "Nothing to uninstall for appname '$APPNAME'."
    return
  fi

  cat <<NOTE

Plugin data and state were left in place. Remove them manually if you no longer need them:
  rm -rf "$HOME/.local/share/$APPNAME"
  rm -rf "$HOME/.local/state/$APPNAME"
  rm -rf "$HOME/.cache/$APPNAME"
NOTE
}

case $ACTION in
  status) print_status; exit 0 ;;
  uninstall) uninstall; exit 0 ;;
esac

# --- install path --------------------------------------------------------
require_cmd git
require_cmd nvim

if ! nvim --headless --clean +'lua if vim.fn.has("nvim-0.12") == 0 then vim.cmd("cq") end' +qa >/dev/null 2>&1; then
  die "Blak requires Neovim 0.12 or newer."
fi

if [ ! -f "$REPO_ROOT/init.lua" ] || [ ! -d "$REPO_ROOT/lua/blak" ]; then
  die "Could not find init.lua or lua/blak under $REPO_ROOT.
Run this script from inside a blak.nvim checkout (it lives at the repo root)."
fi

install_symlink
install_launcher

path_hint=""
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) path_hint="
Note: $BIN_DIR is not on your PATH. Add it, or launch with:
  NVIM_APPNAME=$APPNAME nvim" ;;
esac

cat <<DONE

blak.nvim is installed for development from:
  $REPO_ROOT

Launch it with:
  $APPNAME$path_hint

Edits in the checkout are live — no reinstall needed. First launch will run
\`:Lazy sync\` to install plugins into:
  $HOME/.local/share/$APPNAME/lazy

To remove: $0 --uninstall${APPNAME:+ --appname $APPNAME}
DONE
