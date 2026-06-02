#!/usr/bin/env sh
#
# tmux status-left renderer (no plugins).
#
# Invoked from ~/.tmux.conf as:
#   status-left "#(~/.tmux/status-left.sh '#{pane_current_path}')"
#
# Emits an already-styled left block (tmux re-parses the `#[...]` format codes
# in this output). The active pane's directory is described by the shared
# detector in ~/.zsh/repo-context.sh (also used by the zsh prompt):
#
#   GitHub repo      ->   owner/repo        + branch   (GitHub icon)
#   other git repo   ->   repo              + branch   (git icon)
#   not a git repo   ->   parent/dir (<=2)             (folder icon)
#
# A worktree icon replaces the branch icon when the pane is in a linked git
# worktree (e.g. one created by workmux) rather than the main checkout.

# --- palette (kept in sync with ~/.tmux.conf) ---------------------------------
base="#2e3440"      # status bar background
seg1_bg="#434c5e"   # repo/path segment background
seg1_fg="#eceff4"   # repo/path segment text
seg2_fg="#81a1c1"   # branch text (blue), shown on the same bg as the path
dirty_fg="#ebcb8b"  # dirty working-tree marker (yellow), mirrors the zsh prompt
pr_fg="#a3be8c"     # github PR link (green), distinct from the branch text
aws_bg="#ebcb8b"    # aws-vault segment background (loud yellow — hard to miss)
aws_fg="#2e3440"    # aws-vault segment text (dark, on the yellow bg)

slant=$(printf '\356\202\260')          # U+E0B0  solid right slant
aws_icon=$(printf '\356\236\255')       # U+E7AD  nf-dev-aws

# Shared repo/path detection (icons, label, branch, dirty state).
. "$HOME/.zsh/repo-context.sh"
repo_context "${1:-$HOME}"

# Open GitHub PR for the current branch (cached + fetched in the background).
repo_github_pr

# aws-vault profile active in the pane. The zsh prompt publishes $AWS_VAULT into
# the @aws_vault tmux option on every redraw (see ~/.zsh/marcqualie.zsh-theme);
# tmux expands it into this arg, empty when no aws-vault session is loaded.
aws_profile="${2:-}"

dirty=""
[ -n "$RC_DIRTY" ] && dirty=" #[fg=$dirty_fg]$RC_DIRTY_GLYPH"

# `last_bg` tracks the trailing background so each new segment can slant out of
# whatever colour came before it (the path/branch/PR share one bg; the aws
# segment punches a yellow block in between).
last_bg="$seg1_bg"

# Repo/path + branch on a single segment: one shared background, no separator
# between them (just a space).
printf '#[fg=%s,bg=%s,bold] %s %s' "$seg1_fg" "$seg1_bg" "$RC_ICON" "$RC_LABEL"

if [ -n "$RC_BRANCH" ]; then
  printf '#[fg=%s,bg=%s,nobold] %s %s%s' "$seg2_fg" "$seg1_bg" "$RC_BICON" "$RC_BRANCH" "$dirty"
fi

# aws-vault session — a loud yellow "<icon> <profile>" block right after the
# branch so it's obvious the current window carries AWS credentials.
if [ -n "$aws_profile" ]; then
  printf ' #[fg=%s,bg=%s]%s' "$last_bg" "$aws_bg" "$slant"
  printf '#[fg=%s,bg=%s,bold] %s %s' "$aws_fg" "$aws_bg" "$aws_icon" "$aws_profile"
  last_bg="$aws_bg"
fi

# Matching GitHub PR rendered as "#123". tmux cannot emit OSC 8 hyperlinks in
# the status line (the renderer drops the escape), so instead the number is a
# clickable `range=user|<number>` region; the MouseDown1Status binding in
# ~/.tmux.conf opens the PR via ~/.tmux/open-pr.sh. The literal '#' is doubled
# (##) so tmux's format parser keeps it instead of reading a format directive.
if [ -n "$RC_PR_NUMBER" ]; then
  [ "$last_bg" != "$seg1_bg" ] && printf ' #[fg=%s,bg=%s]%s' "$last_bg" "$seg1_bg" "$slant"
  printf '#[fg=%s,bg=%s,nobold] #[range=user|%s]##%s#[norange]' \
    "$pr_fg" "$seg1_bg" "$RC_PR_NUMBER" "$RC_PR_NUMBER"
  last_bg="$seg1_bg"
fi

printf ' #[fg=%s,bg=%s,nobold]%s' "$last_bg" "$base" "$slant"
