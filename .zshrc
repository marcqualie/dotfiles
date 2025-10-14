# Custom ZSH extensions + environment
# source $ZSH/oh-my-zsh.sh

setopt prompt_subst
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# Plugins
autoload -U compinit && compinit
autoload -U promptinit && promptinit
autoload -U colors && colors

# Theme
precmd_functions+=(theme_prompt)
source ~/.zsh/marcqualie.zsh-theme

# Customization
source ~/.zsh/keybindings.zsh
source ~/.zsh/aliases.sh
source ~/.zsh/claude.sh

# Override default editors
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='code -w'
fi
export BUNDLER_EDITOR=code

normalize_path

