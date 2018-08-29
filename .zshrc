ZSH_THEME="../../.zsh/marcqualie"
COMPLETION_WAITING_DOTS="true"

export ZSH=/Users/marc/.oh-my-zsh
export SHELL=/usr/local/bin/zsh
export UPDATE_ZSH_DAYS=7
export LANG=en_US.UTF-8
export BASHDOWN_DEFAULT_COMMAND="open -a /Applications/Google\ Chrome.app"

plugins=(git)

# Some homebrew forumlae install to /usr/local/sbin
export PATH=/usr/local/sbin:$PATH

# Android Development
export ANT_HOME=/usr/local/opt/ant
export MAVEN_HOME=/usr/local/opt/maven
export GRADLE_HOME=/usr/local/opt/gradle
export ANDROID_HOME=/usr/local/opt/android-sdk
export ANDROID_NDK_HOME=/usr/local/opt/android-ndk
export PATH=${PATH}:${ANDROID_HOME}/tools
export PATH=${PATH}:${ANDROID_HOME}/platform-tools

# Kubernetes
export PATH=$HOME/.conduit/bin:$PATH

# GPG
export GPG_TTY=$(tty)

# Go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

source $ZSH/oh-my-zsh.sh
source ~/.zsh/functions.sh

# Always enable ruby and node, they're kind of a big deal
+env ruby
+env node
+env go

# Editor
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='code -w'
fi
export BUNDLER_EDITOR=code

# Git Aliases
source ~/.zsh/aliases.sh

# https://marcqualie.com/2015/08/remove-deleted-git-branches
alias git-branch-cleanup="git branch -vv | grep gone | awk '{print $1}' | xargs git branch -D"

# Vault
export VAULT_ADDR='http://127.0.0.1:8200'
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/vault vault
