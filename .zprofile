if [[ "$OSTYPE" == darwin* ]]; then
  # The following lines were added by Docker Desktop to add commands to your PATH.
  export PATH="$PATH:$HOME/.docker/bin"
  # End of Docker Desktop section.

  # path_helper in /etc/zprofile moves system dirs first; put version managers back ahead of them
  export PATH="$HOME/.rbenv/shims:$HOME/.nodenv/shims:/opt/homebrew/bin:$PATH"
fi

# Private settings that don't belong in a public repo (gitignored).
[[ -f ~/.dotfiles/.zshenv.private ]] && source ~/.dotfiles/.zshenv.private
