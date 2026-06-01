#!/usr/bin/env sh
#
# tmux status-left renderer (no plugins).
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
seg2_fg="#81a1c1"   # branch text (blue), shown on the same bg as the path
dirty_fg="#ebcb8b"  # dirty working-tree marker (yellow), mirrors the zsh prompt

# --- glyphs (Nerd Font: CascadiaMonoNF), built via octal to keep this ASCII ---
gh_icon=$(printf '\357\202\233')        # U+F09B  GitHub mark
git_icon=$(printf '\356\234\202')       # U+E702  git
folder_icon=$(printf '\357\201\273')    # U+F07B  folder
branch_icon=$(printf '\357\204\246')          # U+F126  branch (normal checkout)
worktree_branch_icon=$(printf '\356\251\243') # U+EA63  branch (linked worktree)
slant=$(printf '\356\202\260')          # U+E0B0  solid right slant
dirty_glyph=$(printf '\342\234\227')    # U+2717  ballot X (dirty working tree)

dir="${1:-$HOME}"
icon=""
label=""
branch=""
bicon=""
dirty=""

if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # Current branch, falling back to a short SHA when HEAD is detached.
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" symbolic-ref --short HEAD 2>/dev/null)
  [ -n "$branch" ] || branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" rev-parse --short HEAD 2>/dev/null)

  # Linked worktrees live under <repo>/.git/worktrees/<name>; swap the branch
  # icon to signal a worktree rather than appending a second glyph.
  bicon=$branch_icon
  case "$(git -C "$dir" rev-parse --git-dir 2>/dev/null)" in
    */worktrees/*) bicon=$worktree_branch_icon ;;
  esac

  # Yellow cross when the working tree is dirty (untracked counts), mirroring
  # parse_git_dirty in ~/.zsh/git.zsh.
  if [ -n "$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" status --porcelain 2>/dev/null)" ]; then
    dirty=" #[fg=$dirty_fg]$dirty_glyph"
  fi

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

# Repo/path + branch on a single segment: one shared background, no separator
# between them (just a space), then one slant into the bar background.
printf '#[fg=%s,bg=%s,bold] %s %s' "$seg1_fg" "$seg1_bg" "$icon" "$label"

if [ -n "$branch" ]; then
  printf '#[fg=%s,bg=%s,nobold] %s %s%s' "$seg2_fg" "$seg1_bg" "$bicon" "$branch" "$dirty"
fi

printf ' #[fg=%s,bg=%s,nobold]%s' "$seg1_bg" "$base" "$slant"
