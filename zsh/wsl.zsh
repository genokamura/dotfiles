# wsl.zsh  --  WSL2 specific integration (sourced only when running under WSL)

# Bail out early on non-WSL systems.
if ! grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
  return 0
fi

export IS_WSL=1

# Find the Windows user profile / drives via interop if available.
export WIN_HOME="$(wslpath "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')" 2>/dev/null)"

# Open files / URLs in the Windows default app.
if command -v wslview >/dev/null 2>&1; then
  alias open='wslview'
elif command -v explorer.exe >/dev/null 2>&1; then
  open() { explorer.exe "$(wslpath -w "${1:-.}" 2>/dev/null || echo "$1")"; }
fi
export BROWSER='wslview'

# Clipboard: prefer win32yank, fall back to clip.exe / PowerShell.
# `cb`  : copy stdin   (e.g. `echo hi | cb`)
# `cbp` : paste to stdout
if command -v win32yank.exe >/dev/null 2>&1; then
  alias cb='win32yank.exe -i --crlf'
  alias cbp='win32yank.exe -o --lf'
elif command -v clip.exe >/dev/null 2>&1; then
  alias cb='clip.exe'
  cbp() { powershell.exe -NoProfile -Command Get-Clipboard 2>/dev/null | tr -d '\r'; }
fi

# Quieten noisy interop warnings and keep $DISPLAY sane for GUI apps if X is up.
unsetopt BG_NICE 2>/dev/null || true
