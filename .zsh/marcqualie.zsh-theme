# Shows parent directory if within source code base directory
# e.g ~/src/project1/web shows "project1/web" instead of just "web" for ambiguous diectories
#
# Based on https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/robbyrussell.zsh-theme

function maybe_src_path() {
  local wd=$(pwd)
  if [[ "${wd}" =~ '/src/[^/]+/' ]]; then
    local parent=$(dirname "$wd" | xargs basename)
    echo "%{$fg[grey]%}$parent/$fg[cyan]%c"
  else
    echo "%c"
  fi
}

local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT='${ret_status} %{$fg[cyan]$(maybe_src_path)%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
