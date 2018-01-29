#!/bin/sh
# Script for setting up Debian 9 for Duncan from a minimal install
# So much left todo, mostly notes for now on ZSH dependencies

# Enable non-free

# Apt Update
sudo apt update

# Basic firmware
sudo apt install -y \
  firmware-linux-nonfree

# Xorg and graphics
sudo apt install -y \
  xorg \
  xserver-xorg \
  nvidia-driver # TODO: Make this system generic

# i3 environment
sudo apt install -y \
  i3 \
  network-manager-gnome \
  rofi \
  scrot

# Utils
# sudo apt install -y \

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
  zsh \
  silversearcher-ag \
  direnv

# NeoVim Setup
sudo apt install -y \
  neovim
