#!/usr/bin/env sh
#
# repo-context.sh — shared repo/path detection for the zsh prompt and the tmux
# status bar, so both describe the current directory identically:
#
#   GitHub repo      ->   owner/repo   (GitHub icon)
#   other git repo   ->   repo         (git icon)
#   not a git repo   ->   parent/dir   (folder icon, <=2 components)
#
# Source this file once, then call `repo_context <dir>`; it populates the RC_*
# globals below. Callers apply their own colouring (zsh prompt escapes vs. tmux
# `#[...]` format codes). Git lookups are read-only (GIT_OPTIONAL_LOCKS=0).

# --- glyphs (Nerd Font: CascadiaMonoNF), built via octal to keep this ASCII ---
RC_GH_ICON=$(printf '\357\202\233')             # U+F09B  GitHub mark
RC_GIT_ICON=$(printf '\356\234\202')            # U+E702  git
RC_FOLDER_ICON=$(printf '\357\201\273')         # U+F07B  folder
RC_BRANCH_ICON=$(printf '\357\204\246')         # U+F126  branch (normal checkout)
RC_WORKTREE_BRANCH_ICON=$(printf '\356\251\243') # U+EA63 branch (linked worktree)
RC_DIRTY_GLYPH=$(printf '\342\234\227')         # U+2717  ballot X (dirty working tree)

# repo_context <dir>
# Populates:
#   RC_ICON     icon glyph for the directory (github / git / folder)
#   RC_KIND     one of: github | git | folder
#   RC_LABEL    owner/repo (github), repo (other git), or parent/dir (folder)
#   RC_BRANCH   current branch or short SHA (empty when not a git repo)
#   RC_BICON    branch icon (worktree variant inside a linked worktree)
#   RC_DIRTY    1 when the working tree is dirty, else empty
#   RC_DETACHED 1 when HEAD is detached (RC_BRANCH holds a short SHA, not a ref)
repo_context() {
  RC_ICON=""; RC_KIND=""; RC_LABEL=""; RC_BRANCH=""; RC_BICON=""; RC_DIRTY=""; RC_DETACHED=""
  rc_dir="${1:-$HOME}"

  if git -C "$rc_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Current branch, falling back to a short SHA when HEAD is detached.
    RC_BRANCH=$(GIT_OPTIONAL_LOCKS=0 git -C "$rc_dir" symbolic-ref --short HEAD 2>/dev/null)
    [ -n "$RC_BRANCH" ] || { RC_DETACHED=1; RC_BRANCH=$(GIT_OPTIONAL_LOCKS=0 git -C "$rc_dir" rev-parse --short HEAD 2>/dev/null); }

    # Linked worktrees live under <repo>/.git/worktrees/<name>; swap the branch
    # icon to signal a worktree rather than appending a second glyph.
    RC_BICON=$RC_BRANCH_ICON
    case "$(git -C "$rc_dir" rev-parse --git-dir 2>/dev/null)" in
      */worktrees/*) RC_BICON=$RC_WORKTREE_BRANCH_ICON ;;
    esac

    # Dirty when there is any porcelain output (untracked counts), mirroring
    # parse_git_dirty in ~/.zsh/git.zsh.
    if [ -n "$(GIT_OPTIONAL_LOCKS=0 git -C "$rc_dir" status --porcelain 2>/dev/null)" ]; then
      RC_DIRTY=1
    fi

    # Parse host + owner/repo from the origin URL (https, ssh, or scp-like).
    rc_url=$(git -C "$rc_dir" config --get remote.origin.url 2>/dev/null)
    rc_url=${rc_url%.git}
    rc_host=""
    rc_path=""
    case "$rc_url" in
      "") : ;;
      *://*) rc_rest=${rc_url#*://}; rc_rest=${rc_rest#*@}; rc_host=${rc_rest%%/*}; rc_path=${rc_rest#*/} ;;
      *@*:*) rc_rest=${rc_url#*@}; rc_host=${rc_rest%%:*}; rc_path=${rc_rest#*:} ;;
      *) rc_path=$rc_url ;;
    esac
    rc_repo=${rc_path##*/}
    rc_owner=${rc_path%/*}; rc_owner=${rc_owner##*/}

    case "$rc_host" in
      github.com)
        RC_ICON=$RC_GH_ICON
        RC_KIND=github
        RC_LABEL="$rc_owner/$rc_repo"
        ;;
      *)
        RC_ICON=$RC_GIT_ICON
        RC_KIND=git
        if [ -n "$rc_repo" ]; then
          RC_LABEL="$rc_repo"
        else
          RC_LABEL=$(basename "$(git -C "$rc_dir" rev-parse --show-toplevel 2>/dev/null)")
        fi
        ;;
    esac
  else
    # Not a git repo: folder icon + at most the last two path components.
    RC_ICON=$RC_FOLDER_ICON
    RC_KIND=folder
    if [ "$rc_dir" = "$HOME" ]; then
      RC_LABEL="~"
    elif [ "${rc_dir%/*}" = "$HOME" ]; then
      # literal ~ for display, not a path to expand
      # shellcheck disable=SC2088
      RC_LABEL="~/${rc_dir##*/}"
    else
      rc_leaf=${rc_dir##*/}
      rc_parent=${rc_dir%/*}; rc_parent=${rc_parent##*/}
      if [ -n "$rc_parent" ] && [ "$rc_parent" != "$rc_leaf" ]; then
        RC_LABEL="$rc_parent/$rc_leaf"
      else
        RC_LABEL="$rc_leaf"
      fi
    fi
  fi
}

# repo_github_pr
# Resolves an open GitHub pull request for the current branch and populates:
#   RC_PR_NUMBER   PR number (digits only), empty when none/unknown
#   RC_PR_URL      web URL of the PR, empty when none/unknown
#
# Must be called after repo_context (uses RC_KIND/RC_LABEL/RC_BRANCH). The
# `gh pr list` lookup is a network call, so results are cached on disk and the
# refresh runs detached in the background: the status bar reads a cached answer
# (or nothing on the very first sighting) and never blocks. Requires the GitHub
# CLI (`gh`); silently no-ops when it is missing or unauthenticated.
repo_github_pr() {
  RC_PR_NUMBER=""; RC_PR_URL=""
  [ "$RC_KIND" = github ] || return 0      # only github.com origins
  [ -z "$RC_DETACHED" ] || return 0        # a detached SHA is not a PR head
  [ -n "$RC_BRANCH" ] || return 0
  command -v gh >/dev/null 2>&1 || return 0

  rc_pr_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-status"
  # Cache key is repo + branch with path separators flattened.
  rc_pr_key=$(printf '%s@%s' "$RC_LABEL" "$RC_BRANCH" | tr '/ :@' '____')
  rc_pr_cache="$rc_pr_cache_dir/pr-$rc_pr_key"

  # Use whatever the last lookup found (cache line is "<number> <url>" or "none").
  if [ -f "$rc_pr_cache" ]; then
    rc_pr_line=$(cat "$rc_pr_cache" 2>/dev/null)
    case "$rc_pr_line" in
      none|"") : ;;
      *) RC_PR_NUMBER=${rc_pr_line%% *}; RC_PR_URL=${rc_pr_line#* } ;;
    esac
  fi

  # Refresh in the background when the cache is missing or older than 5 minutes.
  if [ -z "$(find "$rc_pr_cache" -mmin -5 2>/dev/null)" ]; then
    ( rc_github_pr_fetch "$RC_LABEL" "$RC_BRANCH" "$rc_pr_cache" >/dev/null 2>&1 & )
  fi
}

# rc_github_pr_fetch <owner/repo> <branch> <cache-file>
# Background worker: queries the GitHub CLI for the open PR whose head is
# <branch> and writes "<number> <url>" (or "none") to <cache-file> atomically.
# Single-flighted via a lock dir so overlapping status ticks fire one fetch.
rc_github_pr_fetch() {
  _repo=$1; _branch=$2; _cache=$3
  mkdir -p "$(dirname "$_cache")" 2>/dev/null

  _lock="$_cache.lock"
  if [ -d "$_lock" ]; then
    # Fresh lock => another fetch is in flight; stale lock => reclaim it.
    [ -n "$(find "$_lock" -mmin -1 2>/dev/null)" ] && return 0
    rmdir "$_lock" 2>/dev/null
  fi
  mkdir "$_lock" 2>/dev/null || return 0

  _pr=$(gh pr list --repo "$_repo" --head "$_branch" --state open \
          --json number,url --jq '.[0] | select(.number) | "\(.number) \(.url)"' 2>/dev/null)
  [ -n "$_pr" ] || _pr=none
  printf '%s\n' "$_pr" > "$_cache.tmp" 2>/dev/null && mv "$_cache.tmp" "$_cache" 2>/dev/null

  rmdir "$_lock" 2>/dev/null
}
