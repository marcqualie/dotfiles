# Custom ZSH extensions + environment
# source $ZSH/oh-my-zsh.sh

setopt prompt_subst
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# Plugins
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
autoload -U compinit
local -a zcd=(~/.zcompdump(N.mh+24))
if (( $#zcd )); then
  compinit
else
  compinit -C
fi
autoload -U promptinit && promptinit
autoload -U colors && colors

# Theme
precmd_functions+=(theme_prompt)
source ~/.zsh/marcqualie.zsh-theme

# Customization
source ~/.zsh/keybindings.zsh
source ~/.zsh/aliases.sh
source ~/.zsh/claude.sh
source ~/.zsh/denvig.sh
source ~/.zsh/title.zsh

# Remote (ssh) sessions: match the local Ghostty experience as closely as possible.
if [[ -n $SSH_CONNECTION ]]; then
  # Ghostty exports COLORTERM locally but ssh doesn't forward it; without it
  # CLIs fall back to 256 colours instead of truecolor.
  [[ -z $COLORTERM ]] && export COLORTERM=truecolor

  # A TERM the remote has no terminfo for (e.g. xterm-ghostty from a host not
  # covered by `SetEnv TERM` in ~/.ssh/config) breaks backspace, clear, etc.
  # Prefer Ghostty's bundled terminfo, else fall back to xterm-256color.
  if ! infocmp "$TERM" &>/dev/null; then
    local ghostty_terminfo=/Applications/Ghostty.app/Contents/Resources/terminfo
    if [[ -d $ghostty_terminfo ]] && TERMINFO_DIRS="$ghostty_terminfo:" infocmp "$TERM" &>/dev/null; then
      export TERMINFO_DIRS="$ghostty_terminfo:"
    else
      export TERM=xterm-256color
    fi
  fi

  # GUI editors would open on the remote's screen, not the laptop.
  export EDITOR='nano'
  # .gitconfig's core.editor (code --wait) beats $EDITOR, so override it too.
  export GIT_EDITOR=$EDITOR
  export BUNDLER_EDITOR=$EDITOR
else
  export EDITOR='code -w'
  export BUNDLER_EDITOR=code
fi
export VISUAL=$EDITOR

# Lets gpg (commit signing) prompt on the current terminal when pinentry needs a tty.
export GPG_TTY=$TTY

# Environment detection (triggers +env for project dirs) and direnv.
# Skip for Claude Code / agents so the dynamic direnv hook is never installed in
# non-interactive Bash-tool shells (avoids "is blocked" noise inside worktrees).
# Keyed on multiple markers because not every entrypoint sets CLAUDECODE.
if [[ -z "$CLAUDECODE" && -z "$AI_AGENT" && -z "$CLAUDE_CODE_ENTRYPOINT" ]]; then
  loadenv
  command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

  # Root-cause kill: strip inherited DIRENV_* before launching Claude so its shell
  # snapshot and every Bash-tool shell start clean, regardless of guard/resume timing.
  claude() {
    env -u DIRENV_DIR -u DIRENV_DIFF -u DIRENV_FILE -u DIRENV_WATCHES DIRENV_LOG_FORMAT= \
      command claude "$@"
  }
fi

