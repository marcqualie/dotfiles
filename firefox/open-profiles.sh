#!/usr/bin/env zsh

# macOS blocks scripts (including Finder via AppleScript) from writing to the
# Firefox profile, so open both folders and ⌥ + drag profile folder contents
# into the firefox profile(s).

open "$HOME/Library/Application Support/Firefox/Profiles"
open "$(cd "$(dirname $0)"; pwd)/profile"
