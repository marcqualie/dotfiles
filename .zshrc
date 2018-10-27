ZSH_THEME="../../.zsh/marcqualie"

export ZSH=/Users/marc/.oh-my-zsh
export SHELL=/usr/local/bin/zsh
export UPDATE_ZSH_DAYS=7
export LANG=en_US.UTF-8
export BASHDOWN_DEFAULT_COMMAND="open -a /Applications/Google\ Chrome.app"

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

# https://marcqualie.com/2015/08/remove-deleted-git-branches
alias git-branch-cleanup="git branch -vv | grep gone | awk '{print $1}' | xargs git branch -D"

# Vault
export VAULT_ADDR='http://127.0.0.1:8200'
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/vault vault
