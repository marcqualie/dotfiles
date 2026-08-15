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

# Override default editors
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='code -w'
fi
export BUNDLER_EDITOR=code

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

