# Terminal title: the command while one runs, the folder at the prompt. Herdr names tabs nobody
# named after it (a folder reads as the shell's own, so those show "zsh"); Ghostty and tmux show it too.

autoload -Uz add-zsh-hook

_title_command() {
  local command="${1%%$'\n'*}"
  print -rn -- $'\e]2;'"${${command[1,60]}//[[:cntrl:]]/}"$'\a'
}

_title_folder() {
  print -Pn -- '\e]2;%~\a'
}

add-zsh-hook preexec _title_command
add-zsh-hook precmd _title_folder
