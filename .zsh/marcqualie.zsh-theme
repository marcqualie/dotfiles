# Shows parent directory if within source code base directory
# e.g ~/src/project1/web shows "project1/web" instead of just "web" for ambiguous diectories

source ~/.zsh/git.zsh
source ~/.zsh/repo-context.sh

# High-resolution clock for measuring how long each command takes.
zmodload zsh/datetime 2>/dev/null

function maybe_src_path() {
  local wd=$(pwd)

  if [[ "$wd" = "$HOME" ]]; then
    echo " ~"
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
    prefix="%{$FG[240]%}GH"
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

  echo " ${prefix}%{$fg[cyan]%}${parent}${spacer}%{$fg_bold[cyan]%}${dir}%{$reset_color%}${spacer}"
}

function aws_vault_info() {
  if [ "$AWS_VAULT" != "" ]; then
    echo " %{$fg[blue]%}%{$fg[yellow]%}aws%{$reset_color%}:%{$fg_bold[red]%}${AWS_VAULT}%{$reset_color%}%{$fg[blue]%}%{$reset_color%}"
  fi
}

function ssh_info() {
  if [[ -n "$SSH_CONNECTION" ]]; then
    echo "%{$fg[yellow]%}[-> SSH]%{$reset_color%}"
  fi
}

function color() {
  echo "\e[38;5;${1}m"
}

# --- command timer ------------------------------------------------------------
# preexec stamps the start time; precmd (theme_prompt) reads it back to report
# the duration of the command that just ran. _prompt_ran distinguishes a real
# command from an empty line / fresh shell, so the status line only shows after
# something actually executed.
autoload -U add-zsh-hook

function _prompt_timer_start() {
  _prompt_started=$EPOCHREALTIME
  _prompt_ran=1
}
add-zsh-hook preexec _prompt_timer_start

# Human-friendly elapsed time: ms under a second, seconds under a minute, then
# Xm Ys. Input is a float number of seconds.
function _format_duration() {
  local d=$1
  if (( d < 1 )); then
    printf '%.0fms' $(( d * 1000 ))
  elif (( d < 60 )); then
    printf '%.1fs' $d
  else
    local secs=${d%.*}
    printf '%dm%02ds' $(( secs / 60 )) $(( secs % 60 ))
  fi
}

# Two-line status block printed inside tmux after a command finishes:
#   <blank>
#   ● <duration>          (green dot for success, red dot + code for failure)
#   <blank>
function _print_status_line() {
  local exit=$1
  local circle elapsed
  if [[ $exit -eq 0 ]]; then
    circle="%{$fg[green]%}●%{$reset_color%}"
  else
    circle="%{$fg[red]%}●%{$reset_color%} %{$fg[red]%}${exit}%{$reset_color%}"
  fi
  elapsed=$(_format_duration ${_prompt_started:+$(( EPOCHREALTIME - _prompt_started ))})
  print -P ""
  print -P "${circle} %{$FG[240]%}${elapsed}%{$reset_color%}"
  print -P ""
}

theme_prompt() {
  # Capture the just-finished command's exit code first, before anything else
  # clobbers $?.
  local exit_code=$?

  if [[ -n "$TMUX" ]]; then
    # Status line for the command that just ran (skipped on a fresh shell or an
    # empty line, where preexec never fired).
    if [[ -n "$_prompt_ran" ]]; then
      _print_status_line $exit_code
      unset _prompt_ran
    fi

    # ┏ <icon> <owner/repo | path>
    # ┗ $
    repo_context "$PWD"
    PROMPT="%{$FG[240]%}┏ %{$fg[cyan]%}${RC_ICON} %{$fg_bold[cyan]%}${RC_LABEL}%{$reset_color%}"$'\n'
    PROMPT+="%{$FG[240]%}┗ %{$reset_color%}\$ "
  else
    PROMPT="$(ssh_info)$(maybe_src_path)$(aws_vault_info)$(git_prompt_info) "
  fi
  if [ "$INCOGNISHELL" -eq "1" ]; then
    PROMPT=" 🤫🙈$PROMPT"
  fi
}

function incognishell() {
  INCOGNISHELL="1" script -e /dev/null $SHELL
}

ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[yellow]%}✗"
# ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✓"
