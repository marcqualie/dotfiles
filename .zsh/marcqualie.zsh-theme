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

  # If we could detect the PWD when the shell booted, we can use that to enhance
  if [[ "$VSCODE_WORKSPACE_ROOT" != "" && "$ORIGINAL_PWD" != "" ]]; then
    parent="$(basename $ORIGINAL_PWD)"
    if [[ "$parent" == " " ]]; then; parent = ""; fi
    prefix=""
    dir=$(pwd)
    dir="${dir/$ORIGINAL_PWD\// }"
    dir="${dir/$ORIGINAL_PWD/}"
    separator=""
    spacer=""
  fi

  echo "${prefix}%{$fg[cyan]%}${parent}${spacer}%{$fg_bold[cyan]%}${dir}%{$reset_color%}${spacer}"
}

function aws_vault_info() {
  if [ "$AWS_VAULT" != "" ]; then
    echo "%{$fg[blue]%}%{$fg[yellow]%}aws%{$reset_color%}:%{$fg_bold[red]%}${AWS_VAULT}%{$reset_color%}%{$fg[blue]%}%{$reset_color%} "
  fi
}

function color() {
  echo "\e[38;5;${1}m"
}

PROMPT='$(maybe_src_path) $(aws_vault_info)$(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})" # ✓
