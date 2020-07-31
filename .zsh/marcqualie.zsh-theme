# Shows parent directory if within source code base directory
# e.g ~/src/project1/web shows "project1/web" instead of just "web" for ambiguous diectories

function maybe_src_path() {
  local wd=$(pwd)
  if [[ "$wd" = "$HOME" ]]; then
    echo "~"
    return
  fi

  local projdir="$HOME/src"
  local parent=$(dirname "$wd")
  local dir=$(basename "$wd")
  local prefix=""
  local separator="%{$fg[black]%}/"
  local spacer=" "
  if [[ "$wd" =~ "$GOPATH/src/" ]]; then
    prefix="%{$fg[green]%}go "
  elif [[ "$wd" =~ "$projdir" ]]; then
    prefix="%{$FG[240]%}github.com%{$fg[black]%}/"
  fi
  parent="${parent/$GOPATH\/src\//}"
  parent="${parent/$GOPATH\/src/}"
  parent="${parent/$projdir\/}"
  parent="${parent/$projdir/}"
  parent="${parent/$HOME\//~/}"
  parent="${parent/$HOME/~}"
  [[ "$parent" == "" ]] && separator=""
  if [[ "$wd" = "$projdir" ]]; then
    parent=""
    separator=""
    dir=""
    prefix="%{$FG[240]%}github.com"
  fi

  # In vscode there is less horitzontal real estate, we can strip out the project root
  if [[ "$VSCODE_WORKSPACE_ROOT" != "" ]]; then
    parent="$(basename $VSCODE_WORKSPACE_ROOT)"
    if [[ "$parent" == " " ]]; then; parent = ""; fi
    prefix=""
    dir=$(pwd)
    dir="${dir/$VSCODE_WORKSPACE_ROOT\// }"
    dir="${dir/$VSCODE_WORKSPACE_ROOT/}"
    separator=""
    spacer=""
  fi

  echo "${prefix}%{$fg[cyan]%}${parent}${spacer}%{$fg_bold[cyan]%}${dir}%{$reset_color%}${spacer}"
}

function color() {
  echo "\e[38;5;${1}m"
}

PROMPT='$(maybe_src_path) $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})" # ✓
