#!/usr/local/bin/zsh

cds() {
  cd ~/src/$1
}

cd() {
  builtin cd $1
  loadenv
}



loadenv() {
  if [[ -f Gemfile ]]; then; +env ruby; fi
  if [[ -f package.json ]]; then; +env node; fi
  if [[ $(ls -1 | grep '.go$' | wc -l | awk '{$1=$1};1') != '0' ]]; then; +env go; fi
}



flushdns () {
  dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
  sudo brew services restart dnsmasq
}



update-dotfiles() {
  cd ~/.dotfiles
  git pull --rebase
  ~/.dotfiles/script/update
  source ~/.zshrc
  cd -
}



boost-timemachine() {
  sudo sysctl debug.lowpri_throttle_enabled=0
}



typeset -AHg envz
function +env() {
  local cmd="${1}env"
  case $1 in
    node) cmd="nodenv" ;;
    ruby) cmd="rbenv" ;;
    python) cmd="pyenv" ;;
  esac
  if [ "$envz[$cmd]" != "" ]; then
    echo "+env ${cmd} ${fg[black]}(cached)${reset_color}"
    return 1
  else
    echo "+env ${cmd}"
  fi
  envz[$cmd]=$cmd

  # echo "Initializing ${cmd}"
  eval "$(${cmd} init -)"

  # Each of these tools put their own path at the front, we don't want that
  loadprepath
}



# Ensure our own paths are user first
function loadprepath() {
  PREPATH="bin:./node_modules/.bin:"
  export PATH=$PREPATH${PATH/$PREPATH/}
}
