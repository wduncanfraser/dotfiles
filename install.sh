#!/bin/bash
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
  pulseaudio \
  pavucontrol \
  feh \
  rofi \
  scrot \
  rxvt-unicode-256color

# Utils
sudo apt install -y \
  curl \
  gawk \
  htop \
  wget \
  imagemagick \
  libnotify-bin

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

# Manual installs
# Chrome
mkdir -p ~/temp
pushd ~/temp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb

# VSCode
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt update
sudo apt install -y \
	apt-transport-https \ # Needed for https repos
	code

# Slack
wget https://downloads.slack-edge.com/linux_releases/slack-desktop-3.0.5-amd64.deb
sudo apt install -y ./slack-desktop-3.0.5-amd64.deb

popd