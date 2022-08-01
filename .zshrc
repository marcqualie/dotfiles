# Custom ZSH extensions + environment
source $ZSH/oh-my-zsh.sh
source ~/.zsh/aliases.sh

# Disable some default systems loading
export DISABLE_SPRING=true

# Override default editors
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='code -w'
fi
export BUNDLER_EDITOR=code
