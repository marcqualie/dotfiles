# Shows parent directory if within source code base directory
# e.g ~/src/project1/web shows "project1/web" instead of just "web" for ambiguous diectories

source ~/.zsh/git.zsh
source ~/.zsh/repo-context.sh

# High-resolution clock for measuring how long each command takes.
zmodload zsh/datetime 2>/dev/null

# Faint/dim SGR attribute — renders the same hue at reduced intensity (the
# terminal equivalent of opacity). Used to dim the frame corners while keeping
# them standard cyan. A real ESC char so it works in PROMPT expansion, not just
# `print -P`.
FAINT=$'\e[2m'

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

# "<icon> <host>" in yellow when this shell was reached over ssh, so it's
# obvious which machine a remote session is on. SSH_CONNECTION also reaches new
# tmux panes via tmux's default update-environment when attaching over ssh.
#
# Nerd Font glyph built via octal to keep this file ASCII, like repo-context.sh.
SSH_ICON=$(printf '\363\260\214\230')  # U+F0318  nf-md-lan_connect
#
# Herdr tabs (HC_TERMINAL_ID set) are spawned by the local herdr-core daemon,
# never by sshd, so they don't inherit SSH_CONNECTION even when viewed over ssh.
# For those, check for a `herdr-core connect` client whose parent is an
# sshd-session, i.e. someone attached remotely. Note the tab may be viewed
# locally at the same time; this only knows a remote viewer exists. pgrep
# costs ~30ms per call, so the answer is cached for 10s.
function _herdr_ssh_viewer() {
  if (( EPOCHSECONDS - ${_herdr_ssh_checked:-0} >= 10 )); then
    _herdr_ssh_checked=$EPOCHSECONDS
    _herdr_ssh_remote=
    local sshd_pids
    sshd_pids=$(pgrep -d, sshd-session) &&
      pgrep -qf -P "$sshd_pids" 'herdr-core connect' &&
      _herdr_ssh_remote=1
  fi
  [[ -n $_herdr_ssh_remote ]]
}

# Orca terminals are likely viewed remotely, and like Herdr tabs they don't come
# from sshd, so they always show the host. TERM_PROGRAM alone would miss tmux
# inside Orca, which overwrites it; the terminal handle survives that.
#
# Sets REPLY rather than echoing so it runs in the current shell (no $(...)
# subshell) and the Herdr cache above survives between prompts.
function ssh_info() {
  REPLY=
  if [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" ]] ||
     [[ -n "$ORCA_TERMINAL_HANDLE" || "$TERM_PROGRAM" == Orca ]] ||
     { [[ -n "$HC_TERMINAL_ID" ]] && _herdr_ssh_viewer; }; then
    REPLY=" %F{yellow}${SSH_ICON} ${HOST%%.*}%f"
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

# Status line printed inside tmux after a command finishes. The ┗ corner ties
# it to the prompt block of the command that just ran:
#   ┗ ● <duration>        (green dot for success, red dot + code for failure)
function _print_status_line() {
  local exit=$1
  local circle elapsed
  if [[ $exit -eq 0 ]]; then
    circle="%{$fg[green]%}●%{$reset_color%}"
  else
    circle="%{$fg[red]%}●%{$reset_color%} %{$fg[red]%}${exit}%{$reset_color%}"
  fi
  elapsed=$(_format_duration ${_prompt_started:+$(( EPOCHREALTIME - _prompt_started ))})
  print -P "%{${FAINT}$fg[cyan]%}┗ %{$reset_color%}${circle} %{$fg[240]%}${elapsed}%f"
  print ""
}

theme_prompt() {
  # Capture the just-finished command's exit code first, before anything else
  # clobbers $?.
  local exit_code=$?

  # Publish the aws-vault session into a pane-scoped tmux option so the status
  # bar can surface it — same detection as aws_vault_info above, but the status
  # bar runs in a separate process and can't read this shell's $AWS_VAULT, so
  # we hand it over here. Cleared when no session is loaded. tmux-only; outside
  # tmux the session is surfaced in the prompt itself (see rc_aws below).
  if [[ -n "$TMUX" ]]; then
    if [[ -n "$AWS_VAULT" ]]; then
      tmux set-option -p @aws_vault "$AWS_VAULT" 2>/dev/null
    else
      tmux set-option -pu @aws_vault 2>/dev/null
    fi
  fi

  # Status line for the command that just ran (skipped on a fresh shell or an
  # empty line, where preexec never fired).
  if [[ -n "$_prompt_ran" ]]; then
    _print_status_line $exit_code
    unset _prompt_ran
  fi

  # ┏ <icon> <owner/repo | path>[ <folder> <sub/path>]
  # ┗ $
  # Outside the repo root, append the folder icon + path from the root in a
  # faded grey so the bright repo label stays the anchor and the sub-path
  # reads as context.
  repo_context "$PWD"
  local rc_sub=""
  [[ -n "$RC_SUBPATH" ]] && rc_sub=" %F{240}${RC_FOLDER_ICON} ${RC_SUBPATH}%f"
  # No tmux status bar outside tmux, so surface the aws-vault session inline.
  local rc_aws=""
  [[ -z "$TMUX" ]] && rc_aws="$(aws_vault_info)"
  ssh_info
  local rc_ssh=$REPLY
  PROMPT="%{${FAINT}$fg[cyan]%}┏ %{$reset_color%}%{$fg[cyan]%}${RC_ICON} %{$fg_bold[cyan]%}${RC_LABEL}%{$reset_color%}${rc_sub}${rc_aws}${rc_ssh}"$'\n'
  PROMPT+="%{$fg[cyan]%}\$%{$reset_color%} "
  if [ "$INCOGNISHELL" -eq "1" ]; then
    PROMPT=" 🤫🙈$PROMPT"
  fi
}

function incognishell() {
  INCOGNISHELL="1" script -e /dev/null $SHELL
}

ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[yellow]%}✗"
# ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✓"
