# aliases.zsh  --  short, memorable, keyboard-friendly commands

# --- Neovim ------------------------------------------------------------------
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias vimdiff='nvim -d'

# --- listing (eza if present, else coreutils ls) -----------------------------
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -l --group-directories-first --icons=auto --git'
  alias la='eza -la --group-directories-first --icons=auto --git'
  alias lt='eza --tree --level=2 --icons=auto'
else
  alias ls='ls --color=auto --group-directories-first'
  alias ll='ls -lh --color=auto --group-directories-first'
  alias la='ls -lAh --color=auto --group-directories-first'
fi

# --- navigation --------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# --- safety nets -------------------------------------------------------------
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

# --- grep / search -----------------------------------------------------------
alias grep='grep --color=auto'
command -v rg >/dev/null 2>&1 && alias rg='rg --smart-case'

# --- git ---------------------------------------------------------------------
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gsw='git switch'
alias gb='git branch'
alias gd='git diff'
alias gds='git diff --staged'
alias gp='git push'
alias gpu='git push -u origin HEAD'
alias gl='git pull'
alias gf='git fetch --all --prune'
alias glog='git log --oneline --graph --decorate -20'
alias gloga='git log --oneline --graph --decorate --all'
alias glaz='lazygit'   # no-op if lazygit absent

# --- tmux --------------------------------------------------------------------
alias t='tmux'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tl='tmux list-sessions'

# --- misc --------------------------------------------------------------------
alias reload='exec zsh'
alias path='echo -e ${PATH//:/\\n}'
alias myip='curl -fsSL ifconfig.me; echo'
alias serve='python3 -m http.server'
command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'
alias dotf='cd "$DOTFILES_DIR"'

# --- AI / chat ---------------------------------------------------------------
# `claude` is provided by Claude Code; these are convenience wrappers.
command -v claude >/dev/null 2>&1 && alias cl='claude'
alias ai='claude'
