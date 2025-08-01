#!/bin/zsh

function denvig() {
  +env node
  $HOME/.nodenv/shims/denvig $@
}
