#!/usr/local/bin/zsh

alias gs="git status -s"
alias gd="git diff"
alias gf="git fetch --all --prune"
alias gfo="git fetch origin --prune"
alias gb="git --no-pager branch -vv"
alias gba="git --no-pager branch -avv"
alias gcb="git checkout -b"
alias gco="git checkout"
alias gcom="git checkout main"
alias gcm="git commit -m"
alias gcam="git commit -a -m"
alias gpoh="git push -u origin HEAD"

# https://marcqualie.com/2015/08/remove-deleted-git-branches
alias gbc="git --no-pager branch -vv | grep ': gone]' | awk '{print \$1}' | xargs git branch -D"
alias git-branch-cleanup="gbc"
alias git-set-main-branch="git branch -m master main && git fetch origin && git branch -u origin/main main && git remote set-head origin -a"

alias rspec="bundle exec rspec"

alias tf="terraform"

# Cleanup
alias rm-all-node-modules="find ~/src/ -name node_modules -type d -prune -exec trash {} +"
