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
  unrar \
  openconnect

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
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chrome.deb
sudo apt install -y ./chrome.deb
rm -f chrome.deb

# VSCode
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt update
sudo apt install -y \
	apt-transport-https \ # Needed for https repos
	code

# Virtualbox
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
sudo sh -c 'echo "deb https://download.virtualbox.org/virtualbox/debian stretch contrib" > /etc/apt/sources.list.d/virtualbox.list'
sudo apt update
sudo apt install -y virtualbox-5.2

# Vagrant
wget https://releases.hashicorp.com/vagrant/2.0.2/vagrant_2.0.2_x86_64.deb -O vagrant.deb
sudo apt install -y ./vagrant.deb
sudo rm -f vagrant.deb

# Postman
wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
sudo tar -xzf postman.tar.gz -C /opt
rm -f postman.tar.gz
sudo ln -svf /opt/Postman/Postman /usr/local/bin/postman

# Haskell Stack
# TODO: Consolidate these deps into above installs
sudo apt install -y g++ gcc libc6-dev libffi-dev libgmp-dev make xz-utils zlib1g-dev
wget https://www.stackage.org/stack/linux-x86_64-static -O stack.tar.gz
sudo mkdir -p /opt/stack
sudo tar -xzf stack.tar.gz -C /opt/stack --strip-components 1
rm -f stack.tar.gz
sudo ln -svf /opt/stack/stack /usr/local/bin/stack

# Habitat
wget "https://api.bintray.com/content/habitat/stable/linux/x86_64/hab-%24latest-x86_64-linux.tar.gz?bt_package=hab-x86_64-linux" -O hab.tar.gz
sudo mkdir -p /opt/habitat
sudo tar -xzf hab.tar.gz -C /opt/habitat --strip-components 1
rm -f hab.tar.gz
sudo ln -svf /opt/habitat/hab /usr/local/bin/hab

# Chefdk
wget https://packages.chef.io/files/stable/chefdk/2.4.17/debian/8/chefdk_2.4.17-1_amd64.deb -O chefdk.deb
sudo apt install -y ./chefdk.deb
rm -f chefdk.deb

# Slack
wget https://downloads.slack-edge.com/linux_releases/slack-desktop-3.0.5-amd64.deb -O slack.deb
sudo apt install -y ./slack.deb
rm -f slack.deb

# Steam
wget https://steamcdn-a.akamaihd.net/client/installer/steam.deb
sudo apt install -y ./steam.deb
rm -r steam.deb

#dpkg --add-architecture i386
sudo apt install -y install libgl1-nvidia-glx:i386

popd
