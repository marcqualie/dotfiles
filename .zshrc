ZSH_THEME="robbyrussell"
export ZSH=/Users/marc/.oh-my-zsh
export SHELL=/opt/boxen/homebrew/bin/zsh
export UPDATE_ZSH_DAYS=13
export LANG=en_US.UTF-8
COMPLETION_WAITING_DOTS="true"

fpath=(/opt/boxen/homebrew/share/zsh-completions $fpath)

plugins=(git)

export GOPATH=/Users/marc/go
export GOBIN=$GOPATH/bin

export PATH="bin:/Users/marc/bin:$GOBIN:/opt/boxen/heroku/bin:/opt/boxen/rbenv/shims:/opt/boxen/rbenv/bin:/opt/boxen/ruby-build/bin:node_modules/.bin:/opt/boxen/nodenv/shims:/opt/boxen/nodenv/bin:/opt/boxen/homebrew/bin:/opt/boxen/homebrew/sbin:/opt/boxen/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin"

export BASHDOWN_DEFAULT_COMMAND="open -a /Applications/Google\ Chrome.app"

export ANDROID_HOME=/usr/local/opt/android-sdk

source $ZSH/oh-my-zsh.sh

# Editor
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='atom -w'
fi
export BUNDLER_EDITOR=atom

# Docker
docker-init () {
  eval "$(docker-machine env fgdo)"
}

flushdns () {
  dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
}

# Git Aliases
alias gs="git status -s"
alias gd="git diff"
alias gf="git fetch --all --prune"
alias gfo="git fetch origin --prune"

# https://marcqualie.com/2015/08/remove-deleted-git-branches
alias git-branch-cleanup="git branch -vv | grep gone | awk '{print $1}' | xargs git branch -D"
