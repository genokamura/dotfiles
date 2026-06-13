# functions.zsh  --  small, composable shell helpers

# mkcd: make a directory and step into it.
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# up: climb N directories (`up 3` == ../../..).
up() {
  local n="${1:-1}" p=""
  while ((n-- > 0)); do p+="../"; done
  cd "$p" || return
}

# extract: unpack any common archive format.
extract() {
  local f="$1"
  [ -f "$f" ] || { echo "extract: '$f' is not a file" >&2; return 1; }
  case "$f" in
    *.tar.bz2|*.tbz2) tar xjf "$f" ;;
    *.tar.gz|*.tgz)   tar xzf "$f" ;;
    *.tar.xz)         tar xJf "$f" ;;
    *.tar)            tar xf  "$f" ;;
    *.bz2)            bunzip2 "$f" ;;
    *.gz)             gunzip  "$f" ;;
    *.zip)            unzip   "$f" ;;
    *.7z)             7z x    "$f" ;;
    *.rar)            unrar x "$f" ;;
    *)  echo "extract: don't know how to handle '$f'" >&2; return 1 ;;
  esac
}

# fcd: fuzzy-find a directory and cd into it (needs fzf + fd).
fcd() {
  command -v fzf >/dev/null 2>&1 || { echo "fcd: fzf required" >&2; return 1; }
  local finder="find . -type d -not -path '*/.git/*'"
  command -v fd >/dev/null 2>&1 && finder="fd --type d --hidden --exclude .git"
  local dir; dir="$(eval "$finder" 2>/dev/null | fzf +m)" && cd "$dir"
}

# fkill: pick a process with fzf and kill it.
fkill() {
  command -v fzf >/dev/null 2>&1 || { echo "fkill: fzf required" >&2; return 1; }
  local pid
  pid="$(ps -eo pid,user,%cpu,%mem,command --sort=-%cpu | sed 1d \
    | fzf -m --header='[kill:process]' | awk '{print $1}')"
  [ -n "$pid" ] && echo "$pid" | xargs kill "-${1:-15}"
}

# gclone: clone a repo and cd into it.
gclone() { git clone "$1" && cd "$(basename "${1%.git}")"; }

# note: jot a quick timestamped note into ~/notes.md, or open it with no args.
note() {
  local file="$HOME/notes.md"
  if [ $# -eq 0 ]; then ${EDITOR:-nvim} "$file"; return; fi
  printf '\n## %s\n%s\n' "$(date '+%Y-%m-%d %H:%M')" "$*" >> "$file"
}
