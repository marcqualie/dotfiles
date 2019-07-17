#!/usr/local/bin/zsh

cds() {
  cd ~/src/$1
}

cd() {
  builtin cd $1
  loadenv
}

cdabs() {
  SYMPATH=$(pwd)
  REALPATH=$(pwd -P)
  if [[ "$SYMPATH" == "$REALPATH" ]]; then
    echo "You are already in REALPATH"
  else
    echo "resolving to $REALPATH"
    cd $REALPATH
  fi
}



loadenv() {
  if [[ -f Gemfile ]]; then; +env ruby; fi
  if [[ -f package.json ]]; then; +env node; fi
  if [[ $(ls -1 | grep '.go$' | wc -l | awk '{$1=$1};1') != '0' ]]; then; +env go; fi

  # Load everything when inside a vscode terminal
  if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    +env ruby
    +env node
    +env go
    +env python
  fi

  # Detect symlinked directories
  # This comes up quite a lot when working with Go
  SYMPATH=$(pwd)
  REALPATH=$(pwd -P)
  [[ "$SYMPATH" == "$REALPATH" ]] || echo "\x1b[33mYou have entered a symlink directory. Real path is \x1b[1m${REALPATH/$HOME/~}\x1b[0m"
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
  PREPATH="./bin:./node_modules/.bin:"
  export PATH=$PREPATH${PATH/$PREPATH/}
}
