#!/bin/zsh

function denvig() {
  +env ruby
  $HOME/.rbenv/shims/denvig $@
}
