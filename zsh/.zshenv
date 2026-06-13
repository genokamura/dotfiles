# .zshenv  --  sourced on every shell invocation (login, interactive, scripts)
# Keep this minimal: PATH and a few universal env vars only.

# Locate the dotfiles checkout so .zshrc can source its modules.
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# XDG base directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Prepend ~/.local/bin (nvim, starship, helper scripts, win32yank live here).
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
