#!/usr/bin/env zsh

alias gs="git status -s"
alias gd="git diff"
alias gf="git fetch --all --prune"
alias gfo="git fetch origin --prune"
alias gb="git --no-pager branch -vv"
alias gba="git --no-pager branch -avv"
alias gcb="git checkout -b"
alias gco="git checkout"
alias gcop="git checkout && git pull"
alias gcom="git checkout main"
alias gcomp="git -c core.hooksPath=/dev/null checkout main && git -c core.hooksPath=/dev/null pull && ~/.dotfiles/.githooks/post-checkout"
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

# DNS
alias dns-primary="sudo networksetup -setdnsservers Ethernet 192.168.2.53"
alias dns-backup="sudo networksetup -setdnsservers Ethernet 192.168.2.52"
alias dns-cloudflare="sudo networksetup -setdnsservers Ethernet 1.1.1.1 1.0.0.1"
