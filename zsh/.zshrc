# .zshrc  --  interactive shell configuration
# Lightweight, keyboard-driven, WSL2 friendly.
# Module files live under $DOTFILES_DIR/zsh/ and are sourced below.

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
ZSH_DOTDIR="$DOTFILES_DIR/zsh"

# -----------------------------------------------------------------------------
# History
# -----------------------------------------------------------------------------
HISTFILE="$XDG_STATE_HOME/zsh/history"
mkdir -p "$(dirname "$HISTFILE")"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # share history across sessions
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicate entries
setopt HIST_IGNORE_SPACE      # don't record commands starting with a space
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY       # record timestamps

# -----------------------------------------------------------------------------
# Core shell behaviour
# -----------------------------------------------------------------------------
setopt AUTO_CD                # `foo/` instead of `cd foo/`
setopt AUTO_PUSHD             # cd pushes onto the directory stack
setopt PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS   # allow # comments at the prompt
setopt NO_BEEP
setopt GLOB_DOTS             # include dotfiles in globbing
setopt NUMERIC_GLOB_SORT

# -----------------------------------------------------------------------------
# Completion
# -----------------------------------------------------------------------------
PLUGIN_DIR="$XDG_DATA_HOME/zsh/plugins"
fpath=("$PLUGIN_DIR/zsh-completions/src" $fpath)

autoload -Uz compinit
# Only rebuild the completion dump once a day for fast startup.
_zcompdump="$XDG_CACHE_HOME/zsh/zcompdump"
mkdir -p "$(dirname "$_zcompdump")"
if [[ -n "$_zcompdump"(#qN.mh+24) ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

# -----------------------------------------------------------------------------
# Keybindings (emacs-style line editing, keyboard-first)
# -----------------------------------------------------------------------------
bindkey -e
bindkey '^[[A' history-search-backward   # Up:   prefix search
bindkey '^[[B' history-search-forward    # Down: prefix search
bindkey '^[[1;5C' forward-word           # Ctrl+Right
bindkey '^[[1;5D' backward-word          # Ctrl+Left
bindkey '^[[3~' delete-char
bindkey '^U' backward-kill-line
bindkey '^[w' kill-region

# -----------------------------------------------------------------------------
# Modular config
# -----------------------------------------------------------------------------
for module in exports aliases functions; do
  [ -r "$ZSH_DOTDIR/$module.zsh" ] && source "$ZSH_DOTDIR/$module.zsh"
done

# WSL2-specific tweaks
[ -r "$ZSH_DOTDIR/wsl.zsh" ] && source "$ZSH_DOTDIR/wsl.zsh"

# -----------------------------------------------------------------------------
# Tools
# -----------------------------------------------------------------------------
# fzf key bindings + completion (Ctrl-T, Ctrl-R, Alt-C)
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
  # zsh integration shipped with fzf >= 0.48
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    [ -r /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    [ -r /usr/share/doc/fzf/examples/completion.zsh ]   && source /usr/share/doc/fzf/examples/completion.zsh
  fi
fi

# zoxide (smarter cd) if available — provides `z`
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# -----------------------------------------------------------------------------
# Plugins (loaded last; syntax-highlighting must come after widgets)
# -----------------------------------------------------------------------------
if [ -r "$PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  bindkey '^ ' autosuggest-accept   # Ctrl+Space accepts the suggestion
fi
if [ -r "$PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# -----------------------------------------------------------------------------
# Prompt (last)
# -----------------------------------------------------------------------------
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
