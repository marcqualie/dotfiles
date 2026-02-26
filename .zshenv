export SHELL=/bin/zsh
export LANG=en_US.UTF-8
export ORIGINAL_PWD=$PWD

# Disable tracking
export DO_NOT_TRACK=1
export NO_UPDATE_NOTIFIER=1
export TURBO_TELEMETRY_DISABLED=1
export TURBO_NO_UPDATE_NOTIFIER=1
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# Homebrew
export HOMEBREW_BUNDLE_FILE=~/.dotfiles/.Brewfile

# Go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Make shell functions available and set up PATH.
# Non-interactive scripts get node/ruby via shims on PATH without needing loadenv.
source ~/.zsh/functions.sh
normalize_path
