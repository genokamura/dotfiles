# exports.zsh  --  environment variables

# Editor: prefer Neovim everywhere.
if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
  export VISUAL=nvim
  export MANPAGER='nvim +Man!'   # read man pages in Neovim
  export GIT_EDITOR=nvim
fi

# Pager
export PAGER=less
export LESS='-R --use-color -Dd+r -Du+b'
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"

# Colors
export CLICOLOR=1

# Language / locale (assume UTF-8; harmless if already set)
export LANG="${LANG:-en_US.UTF-8}"

# Point ripgrep at our config (file lives in the dotfiles repo).
[ -r "$DOTFILES_DIR/ripgrep/.ripgreprc" ] && export RIPGREP_CONFIG_PATH="$DOTFILES_DIR/ripgrep/.ripgreprc"

# Keep REPL history out of $HOME.
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node/repl_history"

# fnm / volta / cargo / go bins if present
[ -d "$HOME/.cargo/bin" ] && PATH="$HOME/.cargo/bin:$PATH"
[ -d "$HOME/go/bin" ] && PATH="$HOME/go/bin:$PATH"
export PATH
