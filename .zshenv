export ZSH_THEME="../../.zsh/marcqualie"
export ZSH=$HOME/.oh-my-zsh
export SHELL=/bin/zsh
export UPDATE_ZSH_DAYS=7
export LANG=en_US.UTF-8
export ORIGINAL_PWD=$PWD

# Homebrew
export HOMEBREW_BUNDLE_FILE=~/.dotfiles/.Brewfile

# Trigger loadenv as soon as shell is available. Also triggered on directory change
source ~/.zsh/functions.sh
source ~/.zsh/denvig.sh
loadenv
eval "$(direnv hook zsh)"

# Go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH
