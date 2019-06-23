# Dock
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize 48
killall Dock

# Add a space to the Dock
# defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="small-spacer-tile";}; killall Dock

# Keyboard
defaults write NSGlobalDomain InitialKeyRepeat 13
defaults write NSGlobalDomain KeyRepeat 1

# Security
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Finder
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.dock show-process-indicators -bool true
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
