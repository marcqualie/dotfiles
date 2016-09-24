#!/bin/zsh



docker-init () {
  eval "$(docker-machine env fgdo)"
}



flushdns () {
  dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
}



update-dotfiles() {
  cd ~/.dotfiles
  git pull --rebase
  ~/.dotfiles/script/update
  source ~/.zshrc
  cd -
}
