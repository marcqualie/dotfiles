#!/usr/bin/env zsh

DOTFILES_DIR=$(cd "$(dirname "$0")/.."; pwd)
source "$DOTFILES_DIR/script/.shared"

# Dock
defaults_write com.apple.dock autohide -bool true
defaults_write com.apple.dock show-recents -bool false
defaults_write com.apple.dock show-process-indicators -bool true
defaults_write com.apple.dock tilesize -int 48
macos_defaults_changed dock && killall Dock

# Add a space to the Dock
# defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="small-spacer-tile";}'; killall Dock

# Keyboard
# Repeat keys instead of showing the accent menu when holding a key down.
defaults_write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# Faster than the System Settings slider allows (min is 15 / 2).
defaults_write NSGlobalDomain InitialKeyRepeat -int 10
defaults_write NSGlobalDomain KeyRepeat -int 1

# Security
defaults_write com.apple.screensaver askForPassword -int 1
defaults_write com.apple.screensaver askForPasswordDelay -int 0
defaults_write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Finder
defaults_write com.apple.finder AppleShowAllFiles -bool true
defaults_write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults_write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults_write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults_write com.apple.finder ShowRecentTags -bool false
defaults_write NSGlobalDomain AppleShowAllExtensions -bool true
macos_defaults_changed finder && killall Finder

# Zoom patches: https://medium.com/@jonathan.leitschuh/zoom-zero-day-4-million-webcams-maybe-an-rce-just-get-them-to-visit-your-website-ac75c83f4ef5
defaults_write ~/Library/Preferences/us.zoom.config.plist ZDisableVideo -int 1

# Warn if any defaults changed so the user knows to log out for them to apply.
warn_if_macos_defaults_changed
