#!/bin/sh
# Script for setting up Debian 9 for Duncan from a minimal install
# So much left todo, mostly notes for now on ZSH dependencies

# Apt Update
sudo apt update

# Fonts
sudo apt install -y \
  fonts-powerline \
  fonts-hack-ttf \
  fonts-hack-web

# Git Setup
sudo apt install -y \
  git \
  git-extras

# Shell/ZSH Setup
sudo apt install -y \
  zsh

# NeoVim Setup
sudo apt install -y \
  neovim
