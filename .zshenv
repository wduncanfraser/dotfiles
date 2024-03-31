#!/usr/bin/env zsh

# XDG
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

# ZSH Config Dirs
export ZDOTDIR=${ZDOTDIR:-$HOME/.config/zsh}
export ZDATADIR=${XDG_DATA_HOME}/zsh
# where do you want to store your plugins?
export ZPLUGINDIR=${ZDATADIR}/plugins

