#!/usr/bin/env sh
set -eu

APPNAME="${BLAK_APPNAME:-blak}"
REPO_URL="${BLAK_REPO_URL:-https://github.com/binbandit/blak.nvim.git}"
BLAK_REF="${BLAK_REF:-}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BIN_DIR="${BLAK_BIN_DIR:-$HOME/.local/bin}"
TARGET="$CONFIG_HOME/$APPNAME"
LAUNCHER="$BIN_DIR/$APPNAME"

clone_full() {
  if [ -n "$BLAK_REF" ]; then
    git clone --filter=blob:none --depth=1 --branch "$BLAK_REF" "$REPO_URL" "$TARGET"
  else
    git clone --filter=blob:none --depth=1 "$REPO_URL" "$TARGET"
  fi
}

clone_no_checkout() {
  if [ -n "$BLAK_REF" ]; then
    git clone --filter=blob:none --depth=1 --no-checkout --branch "$BLAK_REF" "$REPO_URL" "$TARGET"
  else
    git clone --filter=blob:none --depth=1 --no-checkout "$REPO_URL" "$TARGET"
  fi
}

checkout_runtime_files() {
  git -C "$TARGET" sparse-checkout set --no-cone \
    /.gitignore \
    /.ignore \
    /init.lua \
    /lua/ \
    /doc/ \
    /lazy-lock.json \
    /NEWS.md \
    /README.md \
    /LICENSE \
    /NOTICE \
    /assets/blak-ascii.svg || return 1
  git -C "$TARGET" checkout
}

install_repo() {
  clone_no_checkout
  if checkout_runtime_files; then
    return 0
  fi

  echo "Could not create a sparse runtime checkout; falling back to a full clone." >&2
  rm -rf "$TARGET"
  clone_full
}

case "$APPNAME" in
  "" | */* | . | ..)
    echo "Invalid BLAK_APPNAME: $APPNAME" >&2
    exit 1
    ;;
esac

if ! command -v git >/dev/null 2>&1; then
  echo "git is required" >&2
  exit 1
fi

if ! command -v nvim >/dev/null 2>&1; then
  echo "nvim is required" >&2
  exit 1
fi

nvim_check_output=$(nvim --headless --clean +'lua if vim.fn.has("nvim-0.12") == 0 then vim.cmd("cq") end' +qa 2>&1) || {
  echo "Blak requires Neovim 0.12 or newer." >&2
  if [ -n "$nvim_check_output" ]; then
    printf '%s\n' "$nvim_check_output" >&2
  fi
  exit 1
}

if [ -e "$TARGET" ]; then
  echo "$TARGET already exists" >&2
  echo "Move it aside or set BLAK_APPNAME to install an isolated copy." >&2
  exit 1
fi

install_repo

launcher_status=""
if mkdir -p "$BIN_DIR" 2>/dev/null; then
  if [ -e "$LAUNCHER" ]; then
    launcher_status="$LAUNCHER already exists; leaving it unchanged. Start manually with: NVIM_APPNAME=$APPNAME nvim"
  else
    cat > "$LAUNCHER" <<LAUNCHER
#!/usr/bin/env sh
NVIM_APPNAME="$APPNAME" exec nvim "\$@"
LAUNCHER
    chmod +x "$LAUNCHER"
    case ":$PATH:" in
      *":$BIN_DIR:"*) launcher_status="Created launcher: $LAUNCHER" ;;
      *) launcher_status="Created launcher: $LAUNCHER
Add $BIN_DIR to PATH, or start with: NVIM_APPNAME=$APPNAME nvim" ;;
    esac
  fi
else
  launcher_status="Could not create $LAUNCHER. Start with: NVIM_APPNAME=$APPNAME nvim"
fi

cat <<OUTPUT
Blak installed to $TARGET

Start it with:
  $APPNAME

$launcher_status

Optional shell alias:
  alias $APPNAME='NVIM_APPNAME=$APPNAME nvim'
OUTPUT
