export ZSH_THEME="../../.zsh/marcqualie"

export ZSH=$HOME/.oh-my-zsh
export SHELL=/bin/zsh
export UPDATE_ZSH_DAYS=7
export LANG=en_US.UTF-8
export ORIGINAL_PWD=$PWD

# Homebrew
export PATH=/opt/homebrew/bin:/usr/local/sbin:$PATH
export HOMEBREW_BUNDLE_FILE=~/.dotfiles/.Brewfile

# Go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Custom ZSH extensions + environment
source $ZSH/oh-my-zsh.sh
source ~/.zsh/functions.sh
source ~/.zsh/aliases.sh

# Disable some default systems loading
export DISABLE_SPRING=true

# Trigger loadenv as soon as shell is available. Also triggered on directory change
eval "$(direnv hook zsh)"
loadenv
loadprepath

# Override default editors
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='code -w'
fi
export BUNDLER_EDITOR=code
