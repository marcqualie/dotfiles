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

db-dump() {
  DB_DIR="/Users/$USER/iCloud Drive/Database Backups"
  DB_NAME=$1
  DB_FILE="$DB_DIR/$DB_NAME-$(date +%y%m%d).dump"
  if [ -e $DB_FILE ]; then
    echo "\033[31mBackup file ${DB_FILE} already exists"
    return 127
  fi
  COMMAND="pg_dump -Fc --no-acl --no-owner -h localhost -U $USER $DB_NAME > \"$DB_FILE\""
  echo $COMMAND
  zsh -c "$COMMAND"
  cp $DB_FILE $DB_DIR/$DB_NAME-latest.dump
}

db-restore() {
  DB_DIR="/Users/$USER/iCloud Drive/Database Backups"
  DB_NAME=$1
  DB_FILE="$DB_DIR/$DB_NAME-latest.dump"
  if [ ! -f "$DB_FILE" ]; then
    echo "\033[31mBackup file $DB_FILE does not exist"
    return 127
  fi
  COMMAND="pg_restore --verbose --clean --no-acl --no-owner -h localhost -U $USER -d $DB_NAME \"$DB_FILE\""
  echo $COMMAND
  zsh -c "psql -U $USER -c \"CREATE DATABASE $DB_NAME;\""
  zsh -c "$COMMAND"
}



docker-init () {
  eval "$(docker-machine env fgdo)"
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

dotfiles() {
  cd ~/.dotfiles
}



src() {
  cd ~/src/$1
}



rspec() {
  if [ -f "bin/rspec" ]; then
    bin/rspec $@
    return $?
  fi
  bundle exec rspec $@
}



lock-screen() {
  automator ~/.dotfiles/automator/Lock\ Screen.workflow
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



function vs() {
  echo "\e[1;33mDEPRECATED\e[0;33m: Please just use \e[1mcode\e[0;33m directly\e[0m"
  code $@
}
