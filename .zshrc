ZSH_THEME="../../.zsh/marcqualie"
COMPLETION_WAITING_DOTS="true"

export ZSH=/Users/marc/.oh-my-zsh
export SHELL=/usr/local/bin/zsh
export UPDATE_ZSH_DAYS=7
export LANG=en_US.UTF-8
export BASHDOWN_DEFAULT_COMMAND="open -a /Applications/Google\ Chrome.app"

plugins=(git)

# Android Development
export ANT_HOME=/usr/local/opt/ant
export MAVEN_HOME=/usr/local/opt/maven
export GRADLE_HOME=/usr/local/opt/gradle
export ANDROID_HOME=/usr/local/opt/android-sdk
export ANDROID_NDK_HOME=/usr/local/opt/android-ndk
export PATH=${PATH}:${ANDROID_HOME}/tools
export PATH=${PATH}:${ANDROID_HOME}/platform-tools

export PATH=bin:./node_modules/.bin:$PATH

source $ZSH/oh-my-zsh.sh
source ~/.zsh/functions.sh

# Always enable ruby, it's kind of a big deal
+env ruby
+env node
+env python

# Autojump
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

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
