#!/usr/bin/env bash
# =============================================================================
#  dotfiles installer  --  Neovim + WSL2 centric, keyboard-driven, portable
#
#  Quick start:
#    bash <(curl -fsSL https://raw.githubusercontent.com/genokamura/dotfiles/main/install.sh)
#
#  Or:
#    curl -fsSL https://raw.githubusercontent.com/genokamura/dotfiles/main/install.sh | bash
#
#  Re-running is safe (idempotent). Existing files are backed up to
#  ~/.dotfiles-backup/<timestamp>/ before being replaced with symlinks.
# =============================================================================
set -euo pipefail

# --- configuration -----------------------------------------------------------
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/genokamura/dotfiles.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# --- pretty output -----------------------------------------------------------
if [ -t 1 ]; then
  C_RESET='\033[0m'; C_BOLD='\033[1m'; C_BLUE='\033[34m'
  C_GREEN='\033[32m'; C_YELLOW='\033[33m'; C_RED='\033[31m'
else
  C_RESET=''; C_BOLD=''; C_BLUE=''; C_GREEN=''; C_YELLOW=''; C_RED=''
fi
info()  { printf "${C_BLUE}${C_BOLD}::${C_RESET} %s\n" "$*"; }
ok()    { printf "${C_GREEN}  ✓${C_RESET} %s\n" "$*"; }
warn()  { printf "${C_YELLOW}  !${C_RESET} %s\n" "$*"; }
err()   { printf "${C_RED}  ✗${C_RESET} %s\n" "$*" >&2; }
die()   { err "$*"; exit 1; }

have()  { command -v "$1" >/dev/null 2>&1; }

# --- platform detection ------------------------------------------------------
IS_WSL=0
if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
  IS_WSL=1
fi

OS="$(uname -s)"
ARCH="$(uname -m)"

# =============================================================================
#  steps
# =============================================================================

clone_or_update() {
  info "Fetching dotfiles into $DOTFILES_DIR"
  if [ -d "$DOTFILES_DIR/.git" ]; then
    git -C "$DOTFILES_DIR" fetch --quiet origin "$DOTFILES_BRANCH" \
      && git -C "$DOTFILES_DIR" checkout --quiet "$DOTFILES_BRANCH" \
      && git -C "$DOTFILES_DIR" pull --quiet --ff-only origin "$DOTFILES_BRANCH" \
      && ok "Updated existing checkout" \
      || warn "Could not fast-forward; using current checkout"
  elif [ -d "$DOTFILES_DIR" ] && [ -f "$DOTFILES_DIR/install.sh" ]; then
    ok "Using local checkout at $DOTFILES_DIR"
  else
    have git || die "git is required to clone the dotfiles. Install git first."
    git clone --quiet --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR" \
      && ok "Cloned $DOTFILES_REPO"
  fi
}

apt_packages() {
  if ! have apt-get; then
    warn "apt-get not found; skipping system package install"
    warn "Install manually: git curl zsh tmux ripgrep fd-find fzf unzip build-essential"
    return 0
  fi
  info "Installing system packages (sudo may prompt for your password)"
  local pkgs=(
    git curl wget unzip tar
    zsh tmux
    ripgrep fd-find fzf
    build-essential
    python3 python3-pip
  )
  sudo apt-get update -qq
  sudo apt-get install -y -qq "${pkgs[@]}" >/dev/null
  ok "System packages installed"

  # Ubuntu ships ripgrep's fd as 'fdfind'; make a friendly 'fd' shim.
  if have fdfind && ! have fd; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    ok "Linked fd -> fdfind"
  fi
}

install_neovim() {
  if have nvim; then
    local v; v="$(nvim --version | head -n1)"
    ok "Neovim already installed ($v)"
    return 0
  fi
  info "Installing latest stable Neovim"
  local triple
  case "$ARCH" in
    x86_64|amd64) triple="linux-x86_64" ;;
    aarch64|arm64) triple="linux-arm64" ;;
    *) warn "Unknown arch '$ARCH'; falling back to apt nvim"; sudo apt-get install -y -qq neovim >/dev/null; return 0 ;;
  esac
  local url="https://github.com/neovim/neovim/releases/latest/download/nvim-${triple}.tar.gz"
  local dest="$HOME/.local/share/nvim-release"
  mkdir -p "$dest" "$HOME/.local/bin"
  curl -fsSL "$url" | tar -xz -C "$dest" --strip-components=1 \
    || { warn "Release download failed; falling back to apt"; sudo apt-get install -y -qq neovim >/dev/null; return 0; }
  ln -sf "$dest/bin/nvim" "$HOME/.local/bin/nvim"
  ok "Neovim installed to ~/.local/bin/nvim"
}

install_starship() {
  if have starship; then
    ok "starship already installed"
    return 0
  fi
  info "Installing starship prompt"
  curl -fsSL https://starship.rs/install.sh \
    | sh -s -- --yes --bin-dir "$HOME/.local/bin" >/dev/null \
    && ok "starship installed" \
    || warn "starship install failed (continuing)"
}

install_zsh_plugins() {
  info "Installing zsh plugins"
  local plugdir="$HOME/.local/share/zsh/plugins"
  mkdir -p "$plugdir"
  local -A plugins=(
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
    [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
    [zsh-completions]="https://github.com/zsh-users/zsh-completions"
  )
  for name in "${!plugins[@]}"; do
    local target="$plugdir/$name"
    if [ -d "$target/.git" ]; then
      git -C "$target" pull --quiet --ff-only 2>/dev/null || true
    else
      git clone --quiet --depth 1 "${plugins[$name]}" "$target" 2>/dev/null \
        && ok "cloned $name" || warn "failed to clone $name"
    fi
  done
}

install_wsl_clipboard() {
  [ "$IS_WSL" -eq 1 ] || return 0
  if have win32yank.exe || have win32yank; then
    ok "win32yank already available"
    return 0
  fi
  info "Installing win32yank (WSL2 clipboard bridge)"
  local tmp; tmp="$(mktemp -d)"
  local url="https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip"
  if curl -fsSL "$url" -o "$tmp/win32yank.zip" && unzip -o -q "$tmp/win32yank.zip" -d "$tmp"; then
    mkdir -p "$HOME/.local/bin"
    install -m755 "$tmp/win32yank.exe" "$HOME/.local/bin/win32yank.exe"
    ok "win32yank installed"
  else
    warn "win32yank install failed; clipboard will fall back to clip.exe/powershell"
  fi
  rm -rf "$tmp"
}

# --- symlink engine ----------------------------------------------------------
link() {
  # link <source-relative-to-dotfiles> <absolute-target>
  local src="$DOTFILES_DIR/$1"
  local dst="$2"

  [ -e "$src" ] || { warn "missing source: $1"; return 0; }
  mkdir -p "$(dirname "$dst")"

  # already correctly linked?
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    ok "linked $dst"
    return 0
  fi
  # back up anything in the way
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR$(dirname "$dst")"
    mv "$dst" "$BACKUP_DIR$dst"
    warn "backed up existing $dst"
  fi
  ln -s "$src" "$dst"
  ok "linked $dst"
}

create_symlinks() {
  info "Creating symlinks"
  mkdir -p "$HOME/.config" "$HOME/.local/bin"

  link nvim                  "$HOME/.config/nvim"
  link zsh/.zshrc            "$HOME/.zshrc"
  link zsh/.zshenv           "$HOME/.zshenv"
  link starship/starship.toml "$HOME/.config/starship.toml"
  link git/.gitconfig        "$HOME/.gitconfig"
  link git/.gitignore_global "$HOME/.gitignore_global"
  link tmux/.tmux.conf       "$HOME/.tmux.conf"
  link editorconfig/.editorconfig "$HOME/.editorconfig"

  # executable helpers
  if [ -d "$DOTFILES_DIR/bin" ]; then
    for f in "$DOTFILES_DIR/bin/"*; do
      [ -f "$f" ] || continue
      chmod +x "$f"
      link "bin/$(basename "$f")" "$HOME/.local/bin/$(basename "$f")"
    done
  fi
}

set_default_shell() {
  have zsh || { warn "zsh not installed; skipping default shell change"; return 0; }
  local zsh_path; zsh_path="$(command -v zsh)"
  if [ "${SHELL:-}" = "$zsh_path" ]; then
    ok "zsh is already the default shell"
    return 0
  fi
  info "Setting zsh as the default shell"
  if grep -q "^${zsh_path}$" /etc/shells 2>/dev/null || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null; then
    if chsh -s "$zsh_path" 2>/dev/null; then
      ok "Default shell set to zsh (restart your shell to apply)"
    else
      warn "chsh failed. Run manually: chsh -s $zsh_path"
    fi
  fi
}

print_done() {
  echo
  printf "${C_GREEN}${C_BOLD}All set!${C_RESET}\n"
  echo
  echo "  Next steps:"
  echo "    1. Restart your terminal (or run: exec zsh)"
  echo "    2. Launch Neovim — plugins install automatically on first run:  nvim"
  echo "    3. (WSL2) Make sure ~/.local/bin is on PATH (handled by .zshenv)"
  echo
  echo "  Dotfiles live in: $DOTFILES_DIR"
  [ -d "$BACKUP_DIR" ] && echo "  Replaced files backed up to: $BACKUP_DIR"
  echo
}

# =============================================================================
#  main
# =============================================================================
main() {
  printf "${C_BOLD}dotfiles installer${C_RESET}  (WSL=%s, %s/%s)\n\n" "$IS_WSL" "$OS" "$ARCH"

  # If we're already running from inside a checkout, prefer it.
  local self_dir
  self_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
  if [ -n "$self_dir" ] && [ -f "$self_dir/install.sh" ] && [ -d "$self_dir/nvim" ]; then
    DOTFILES_DIR="$self_dir"
    ok "Running from existing checkout: $DOTFILES_DIR"
  else
    clone_or_update
  fi

  apt_packages
  install_neovim
  install_starship
  install_zsh_plugins
  install_wsl_clipboard
  create_symlinks
  set_default_shell
  print_done
}

main "$@"
