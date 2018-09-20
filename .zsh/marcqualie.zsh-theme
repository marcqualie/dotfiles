# Shows parent directory if within source code base directory
# e.g ~/src/project1/web shows "project1/web" instead of just "web" for ambiguous diectories

function maybe_src_path() {
  local wd=$(pwd)
  if [[ "${wd}" =~ '/src/[^/]+/' ]]; then
    local parent=$(dirname "$wd")
    echo "%{$fg[cyan]%}${parent/$HOME\/src\//} %{$fg_bold[cyan]%}%c%{$reset_color%}"
  else
    echo "%{$fg_bold[cyan]%}%c%{$reset_color%}"
  fi
}

function color() {
  echo "\e[38;5;${1}m"
}

PROMPT='
%{$fg_bold[white]%}$%{$reset_color%} $(maybe_src_path) $(git_prompt_info)
%{$fg_bold[white]%}$%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
