#!/usr/bin/env zsh

# Use denvig via workmux + claude to upgrade dependencides.
# Runs in the current directory, which should be a denvig project directory.
#
# Usage: denvig_upgrade_npm_dependencies [patch|minor|all|package-name]
# Example: `denvig_upgrade_npm_dependencies patch` will upgrade all patch versions of dependencies.
function denvig_upgrade_npm_dependencoes() {
  # ensure this is being run in a denvig project directory (~/src/*/*)
  if [[ ! "$PWD" =~ ^/Users/[^/]+/src/[^/]+/[^/]+$ ]]; then
    echo "This command must be run in a denvig project directory (~/src/*/*)"
    return 1
  fi

  # ensure the current terminal is already inside a tmux session
  if [[ -z "$TMUX" ]]; then
    echo "This command must be run inside a tmux session"
    return 1
  fi

  # the first argument must be "patch" or "minor" or the name of a package
  if [[ "$1" != "patch" && "$1" != "minor" && "$1" != "all" && ! "$1" =~ ^@?[^/]+$ ]]; then
    echo "Usage: denvig_upgrade_npm_dependencies [patch|minor|all|package-name]"
    return 1
  fi

  # Show current outdated dependencies before upgrading
  if [[ "$1" == "patch" || "$1" == "minor" ]]; then
    local outdated
    outdated="$(denvig outdated --semver "$1")"
    if [[ "$outdated" == "No $1-level updates available." ]]; then
      echo "$outdated"
      return 0
    fi
    echo "Current outdated dependencies (before upgrade):"
    echo "$outdated"
  fi

  # start a new workmux window and run the claude skill
  workmux add "denvig-$(date +%s)" -a claude -p "/denvig-upgrade-npm-dependencies $1"
}
