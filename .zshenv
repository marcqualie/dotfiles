export ZSH_THEME="../../.zsh/marcqualie"
export ZSH=$HOME/.oh-my-zsh
export SHELL=/bin/zsh
export UPDATE_ZSH_DAYS=7
export LANG=en_US.UTF-8
export ORIGINAL_PWD=$PWD

# Homebrew
export PATH=/opt/homebrew/bin:/usr/local/sbin:/usr/local/bin/:$PATH
export HOMEBREW_BUNDLE_FILE=~/.dotfiles/.Brewfile

# Trigger loadenv as soon as shell is available. Also triggered on directory change
source ~/.zsh/functions.sh
eval "$(direnv hook zsh)"
loadenv
loadprepath

# Go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH
