#!/usr/bin/env zsh

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



# macos and other tools can interfere with PATH, so we force ordering
function normalize_path() {
  LOCAL_BIN="./node_modules/.bin"
  SHIMS_BIN="$HOME/.nodenv/shims:$HOME/.rbenv/shims"
  HOMEBREW_BIN="/opt/homebrew/bin:/usr/local/sbin:/usr/local/bin"
  PNPM_HOME="$HOME/Library/pnpm"
  export PATH=$LOCAL_BIN:$PNPM_HOME:$SHIMS_BIN:$HOMEBREW_BIN:$PATH

  # Remove duplicate paths and trailing slashes
  path_array=("${(@s/:/)PATH}")
  declare -A seen
  new_path=""
  for dir in "${path_array[@]}"; do
    # Remove trailing slash
    dir="${dir%/}"
    # Skip if already seen
    if [[ -z "${seen[$dir]}" ]]; then
      seen[$dir]=1
      if [[ -z "$new_path" ]]; then
        new_path="$dir"
      else
        new_path="$new_path:$dir"
      fi
    fi
  done
  export PATH="$new_path"
}

# Check if a path is allowed by direnv (pure zsh, no subprocesses)
direnv_path_allowed() {
  local allow_dir=$HOME/.local/share/direnv/allow
  local f allowed_path
  for f in $allow_dir/*(N); do
    allowed_path=$(<$f)
    allowed_path=${allowed_path%/.envrc}
    [[ "$1" == "$allowed_path" ]] && return 0
  done
  return 1
}

loadenv() {
  normalize_path

  # Detect symlinked directories
  # This comes up quite a lot when working with Go
  SYMPATH=$(pwd)
  REALPATH=$(pwd -P)
  [[ "$SYMPATH" == "$REALPATH" ]] || echo "\x1b[33mYou have entered a symlink directory. Real path is \x1b[1m${REALPATH/$HOME/~}\x1b[0m"

  # Only continue if the path is allowed by direnv
  if direnv_path_allowed $PWD -eq 0; then
    if [[ "$PRINT_TRUSTED_DIR" -ne "false" ]]; then
      echo "Trusted directory."
    fi
  else
    return
  fi

  if [[ -f .zshenv.local ]]; then; source .zshenv.local; fi
  if [[ -f Gemfile ]]; then; +env ruby; fi
  if [[ -f .ruby-version ]]; then; +env ruby; fi
  if [[ -f backend/Gemfiile ]]; then; +env ruby; fi
  if [[ -f package.json ]]; then; +env node; fi
  if [[ -f .node-version ]]; then; +env node; fi
  if [[ -f frontend/package.json ]]; then; +env node; fi
  # if [[ $(ls -1 | grep '.go$' | wc -l | awk '{$1=$1};1') != '0' ]]; then; +env go; fi

  # Load everything when inside a vscode terminal
  # if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  #   +env ruby
  #   +env node
  #   +env go
  #   +env python
  # fi
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
    if [[ -o interactive ]]; then
      echo "+env ${cmd} ${fg[black]}(cached)${reset_color}"
    fi
    return 1
  fi
  envz[$cmd]=$cmd

  if [[ -o interactive ]]; then
    echo "+env ${cmd}"
  fi

  # Lazy init: defer eval "$(cmd init -)" until the env manager is actually invoked.
  # Commands like node/ruby already work via shims on PATH.
  eval "function $cmd() {
    unfunction $cmd 2>/dev/null
    eval \"\$(command $cmd init -)\"
    normalize_path
    $cmd \"\$@\"
  }"
}
