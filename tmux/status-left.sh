#!/usr/bin/env sh
#
# tmux status-left renderer (nova-inspired, no plugins).
#
# Invoked from ~/.tmux.conf as:
#   status-left "#(~/.tmux/status-left.sh '#{pane_current_path}')"
#
# Emits an already-styled left block: a folder/path segment plus an optional
# git-branch segment, with slanted powerline borders. tmux re-parses the
# `#[...]` format codes in this output, so we build the whole block here.
#
# Path logic mirrors `maybe_src_path` in ~/.zsh/marcqualie.zsh-theme and the
# read-only git lookup mirrors `__git` / `git_prompt_info` in ~/.zsh/git.zsh:
#   - inside ~/src/<group>/<project>...  ->  "GH <group>/<project>..." (+ branch)
#   - exactly ~/src                      ->  "GH"
#   - $HOME                              ->  "~"
#   - anywhere else                      ->  full path ($HOME shortened to ~)

# --- palette (kept in sync with ~/.tmux.conf) ---------------------------------
base="#2e3440"      # status bar background
path_bg="#434c5e"   # path segment background
path_fg="#eceff4"   # path segment text
branch_bg="#3b4252" # branch segment background
branch_fg="#81a1c1" # branch segment text (nova blue)

# --- glyphs (Nerd Font: CascadiaMonoNF) ---------------------------------------
slant=""           # U+E0B0 solid right-pointing slant
folder=""          # U+F07B folder
git_glyph=""       # U+E0A0 powerline branch

dir="${1:-$HOME}"
src="$HOME/src"
branch=""

if [ "$dir" = "$HOME" ]; then
  label="~"
elif [ "$dir" = "$src" ]; then
  label="GH"
elif [ "${dir#"$src"/}" != "$dir" ]; then
  # Inside ~/src/<group>/<project>...
  label="GH ${dir#"$src"/}"
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" symbolic-ref --short HEAD 2>/dev/null)
else
  case "$dir" in
    "$HOME"/*) label="~${dir#"$HOME"}" ;;
    *) label="$dir" ;;
  esac
fi

# Path segment.
printf '#[fg=%s,bg=%s,bold] %s %s ' "$path_fg" "$path_bg" "$folder" "$label"

if [ -n "$branch" ]; then
  # path -> branch slant, branch segment, branch -> base slant.
  printf '#[fg=%s,bg=%s,nobold]%s' "$path_bg" "$branch_bg" "$slant"
  printf '#[fg=%s,bg=%s] %s %s ' "$branch_fg" "$branch_bg" "$git_glyph" "$branch"
  printf '#[fg=%s,bg=%s,nobold]%s' "$branch_bg" "$base" "$slant"
else
  # path -> base slant.
  printf '#[fg=%s,bg=%s,nobold]%s' "$path_bg" "$base" "$slant"
fi
