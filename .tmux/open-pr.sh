#!/usr/bin/env sh
#
# open-pr.sh — open the GitHub PR clicked in the tmux status-left.
#
# Bound from ~/.tmux.conf as the MouseDown1Status handler. tmux cannot render
# OSC 8 hyperlinks in the status line, so status-left.sh marks the "#123" PR
# number as a `range=user|<number>` region instead; clicking it fires this with
#
#   open-pr.sh '#{mouse_status_range}' '#{pane_current_path}'
#
# The range value is the PR number; the pane path identifies the repo, whose
# GitHub origin reconstructs the PR URL. Non-numeric ranges (e.g. the window
# list) are ignored so the caller can fall back to the default click behaviour.

pr=$1
dir=$2

case "$pr" in
  ""|*[!0-9]*) exit 0 ;;   # not our numeric PR range -> let the default handle it
esac

. "$HOME/.zsh/repo-context.sh"
repo_context "$dir"
[ "$RC_KIND" = github ] || exit 0   # RC_LABEL is owner/repo on github.com

open "https://github.com/$RC_LABEL/pull/$pr" >/dev/null 2>&1
