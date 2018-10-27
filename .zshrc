ZSH_THEME="../../.zsh/marcqualie"

export ZSH=/Users/marc/.oh-my-zsh
export SHELL=/usr/local/bin/zsh
export UPDATE_ZSH_DAYS=7
export LANG=en_US.UTF-8
export BASHDOWN_DEFAULT_COMMAND="open -a /Applications/Google\ Chrome.app"

# Some homebrew forumlae install to /usr/local/sbin
export PATH=/usr/local/sbin:$PATH

# GPG
export GPG_TTY=$(tty)

# Go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

source $ZSH/oh-my-zsh.sh
source ~/.zsh/functions.sh

# Trigger loadenv as soon as shell is available. Also triggered on directory change
loadenv
loadprepath

# Editor
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='code -w'
fi
export BUNDLER_EDITOR=code

# Git Aliases
source ~/.zsh/aliases.sh
