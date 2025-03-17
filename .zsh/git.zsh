# Simplified version of https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/git.zsh

# The git prompt's git commands are read-only and should not interfere with
# other processes. This environment variable is equivalent to running with `git
# --no-optional-locks`, but falls back gracefully for older versions of git.
# See git(1) for and git-status(1) for a description of that flag.
#
# We wrap in a local function instead of exporting the variable directly in
# order to avoid interfering with manually-run git commands by the user.
function __git() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

# Display the current branch and highlight if dirty or not
function git_prompt_info() {
  # exit if not in a git directory
  git rev-parse --is-inside-work-tree &>/dev/null || return

  local branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return

  echo " %{$fg_bold[blue]%}(%{$fg[red]%}$branch%{$fg_bold[blue]%})%{$fg[red]%}$(parse_git_dirty)%{$reset_color%}"
}

function parse_git_dirty() {
  local FLAGS=('--porcelain')
  local STATUS=$(__git status $FLAGS 2> /dev/null | tail -n 1)
  if [[ -n $STATUS ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  else
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
}
