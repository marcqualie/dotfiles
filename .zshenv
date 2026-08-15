export SHELL=/bin/zsh
export LANG=en_US.UTF-8
export ORIGINAL_PWD=$PWD

# Disable tracking
export DO_NOT_TRACK=1
export NO_UPDATE_NOTIFIER=1
export TURBO_TELEMETRY_DISABLED=1
export TURBO_NO_UPDATE_NOTIFIER=1
export DISABLE_TELEMETRY=1
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
export PI_OFFLINE=1

# Homebrew
export HOMEBREW_BUNDLE_FILE=~/.dotfiles/.Brewfile

# Go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Neutralize direnv under Claude Code / agents: non-interactive Bash-tool shells
# inherit stale DIRENV_* state from the launching terminal, which produces
# "is blocked" errors on stdout inside git worktrees and corrupts piping.
# Keyed on multiple markers because not every entrypoint sets CLAUDECODE.
if [[ -n "$CLAUDECODE" || -n "$AI_AGENT" || -n "$CLAUDE_CODE_ENTRYPOINT" ]]; then
  export DIRENV_LOG_FORMAT=                                 # silence direnv logging
  unset DIRENV_DIFF DIRENV_DIR DIRENV_FILE DIRENV_WATCHES   # drop stale trigger state
fi

# Make shell functions available and set up PATH.
# Non-interactive scripts get node/ruby via shims on PATH without needing loadenv.
source ~/.zsh/functions.sh
normalize_path
