#!/usr/bin/env sh
#
# tmux status-left renderer (nova-inspired, no plugins).
#
# Invoked from ~/.tmux.conf as:
#   status-left "#(~/.tmux/status-left.sh '#{pane_current_path}')"
#
# Emits an already-styled left block (tmux re-parses the `#[...]` format codes
# in this output). The left block describes the active pane's directory:
#
#   GitHub repo      ->   owner/repo        + branch   (GitHub icon)
#   other git repo   ->   repo              + branch   (git icon)
#   not a git repo   ->   parent/dir (<=2)             (folder icon)
#
# A worktree icon is appended to the branch when the pane is in a linked git
# worktree (e.g. one created by workmux) rather than the main checkout.
#
# Git lookups are read-only (GIT_OPTIONAL_LOCKS=0, mirroring ~/.zsh/git.zsh).

# --- palette (kept in sync with ~/.tmux.conf) ---------------------------------
base="#2e3440"      # status bar background
seg1_bg="#434c5e"   # repo/path segment background
seg1_fg="#eceff4"   # repo/path segment text
seg2_bg="#3b4252"   # branch segment background
seg2_fg="#81a1c1"   # branch segment text (nova blue)

# --- glyphs (Nerd Font: CascadiaMonoNF), built via octal to keep this ASCII ---
gh_icon=$(printf '\357\202\233')        # U+F09B  GitHub mark
git_icon=$(printf '\356\234\202')       # U+E702  git
folder_icon=$(printf '\357\201\273')    # U+F07B  folder
branch_icon=$(printf '\356\202\240')    # U+E0A0  branch
worktree_icon=$(printf '\357\204\246')  # U+F126  fork (linked worktree)
slant=$(printf '\356\202\260')          # U+E0B0  solid right slant

dir="${1:-$HOME}"
icon=""
label=""
branch=""
wt=""

if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # Current branch, falling back to a short SHA when HEAD is detached.
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" symbolic-ref --short HEAD 2>/dev/null)
  [ -n "$branch" ] || branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" rev-parse --short HEAD 2>/dev/null)

  # Linked worktrees live under <repo>/.git/worktrees/<name>.
  case "$(git -C "$dir" rev-parse --git-dir 2>/dev/null)" in
    */worktrees/*) wt=" $worktree_icon" ;;
  esac

  # Parse host + owner/repo from the origin URL (https, ssh, or scp-like).
  url=$(git -C "$dir" config --get remote.origin.url 2>/dev/null)
  url=${url%.git}
  host=""
  path=""
  case "$url" in
    "") : ;;
    *://*) rest=${url#*://}; rest=${rest#*@}; host=${rest%%/*}; path=${rest#*/} ;;
    *@*:*) rest=${url#*@}; host=${rest%%:*}; path=${rest#*:} ;;
    *) path=$url ;;
  esac
  repo=${path##*/}
  owner=${path%/*}; owner=${owner##*/}

  case "$host" in
    github.com)
      icon=$gh_icon
      label="$owner/$repo"
      ;;
    *)
      icon=$git_icon
      if [ -n "$repo" ]; then
        label="$repo"
      else
        label=$(basename "$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)")
      fi
      ;;
  esac
else
  # Not a git repo: folder icon + at most the last two path components.
  icon=$folder_icon
  if [ "$dir" = "$HOME" ]; then
    label="~"
  elif [ "${dir%/*}" = "$HOME" ]; then
    # literal ~ for display, not a path to expand
    # shellcheck disable=SC2088
    label="~/${dir##*/}"
  else
    leaf=${dir##*/}
    parent=${dir%/*}; parent=${parent##*/}
    if [ -n "$parent" ] && [ "$parent" != "$leaf" ]; then
      label="$parent/$leaf"
    else
      label="$leaf"
    fi
  fi
fi

# Repo/path segment.
printf '#[fg=%s,bg=%s,bold] %s %s ' "$seg1_fg" "$seg1_bg" "$icon" "$label"

if [ -n "$branch" ]; then
  # seg1 -> seg2 slant, branch segment, seg2 -> base slant.
  printf '#[fg=%s,bg=%s,nobold]%s' "$seg1_bg" "$seg2_bg" "$slant"
  printf '#[fg=%s,bg=%s] %s %s%s ' "$seg2_fg" "$seg2_bg" "$branch_icon" "$branch" "$wt"
  printf '#[fg=%s,bg=%s,nobold]%s' "$seg2_bg" "$base" "$slant"
else
  # seg1 -> base slant.
  printf '#[fg=%s,bg=%s,nobold]%s' "$seg1_bg" "$base" "$slant"
fi
