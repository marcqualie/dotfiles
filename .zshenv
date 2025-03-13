export SHELL=/bin/zsh
export LANG=en_US.UTF-8
export ORIGINAL_PWD=$PWD

# Disable tracking
export DO_NOT_TRACK=1
export NO_UPDATE_NOTIFIER=1
export TURBO_TELEMETRY_DISABLED=1
export TURBO_NO_UPDATE_NOTIFIER=1

# Homebrew
export HOMEBREW_BUNDLE_FILE=~/.dotfiles/.Brewfile

# Trigger loadenv as soon as shell is available. Also triggered on directory change
source ~/.zsh/functions.sh
source ~/.zsh/denvig.sh
loadenv
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH
