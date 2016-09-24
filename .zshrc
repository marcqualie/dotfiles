ZSH_THEME="robbyrussell"
COMPLETION_WAITING_DOTS="true"

export ZSH=/Users/marc/.oh-my-zsh
export SHELL=/usr/local/bin/zsh
export UPDATE_ZSH_DAYS=7
export LANG=en_US.UTF-8
export BASHDOWN_DEFAULT_COMMAND="open -a /Applications/Google\ Chrome.app"

#fpath=(/opt/boxen/homebrew/share/zsh-completions $fpath)

plugins=(git)

eval "$(rbenv init -)"
eval "$(nodenv init -)"

source $ZSH/oh-my-zsh.sh
source ~/.zsh/functions.sh

# Editor
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='atom -w'
fi
export BUNDLER_EDITOR=atom

# Git Aliases
alias gs="git status -s"
alias gd="git diff"
alias gf="git fetch --all --prune"
alias gfo="git fetch origin --prune"

# https://marcqualie.com/2015/08/remove-deleted-git-branches
alias git-branch-cleanup="git branch -vv | grep gone | awk '{print $1}' | xargs git branch -D"
