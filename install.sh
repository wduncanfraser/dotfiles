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
  argyll \
  nvidia-driver # TODO: Make this system generic

# i3 environment
sudo apt install -y \
  i3 \
  i3blocks \
  comtpon \
  network-manager-gnome \
  pulseaudio \
  pavucontrol \
  feh \
  rofi \
  scrot \
  rxvt-unicode-256color \
  ranger \
  adwaita-icon-theme \
  gnome-themes-standard

# Utils
sudo apt install -y \
  curl \
  gawk \
  htop \
  wget \
  imagemagick \
  libnotify-bin \
  unrar

# Fonts
sudo apt install -y \
  fonts-powerline \
  fonts-hack-ttf \
  fonts-hack-web

# Graphics Editing
sudo apt install -y \
  gimp

# GPG Setup
sudo apt install -y \
  gnupg

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

# Steam
wget https://steamcdn-a.akamaihd.net/client/installer/steam.deb
sudo apt install -y ./steam.deb

#dpkg --add-architecture i386
sudo apt install -y install libgl1-nvidia-glx:i386

popd
