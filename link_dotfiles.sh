#!/bin/bash
set -e
set -o pipefail

ln -sfnv "${PWD}/config/fish" "${HOME}/.config/fish"
ln -sfnv "${PWD}/config/fontconfig" "${HOME}/.config/fontconfig"
ln -sfnv "${PWD}/config/foot" "${HOME}/.config/foot"
ln -sfnv "${PWD}/config/gtk-3.0" "${HOME}/.config/gtk-3.0"
ln -sfnv "${PWD}/config/mako" "${HOME}/.config/mako"
ln -sfnv "${PWD}/config/nvim" "${HOME}/.config/nvim"
ln -sfnv "${PWD}/config/rofi" "${HOME}/.config/rofi"
ln -sfnv "${PWD}/config/sway" "${HOME}/.config/sway"
ln -sfnv "${PWD}/config/waybar" "${HOME}/.config/waybar"
ln -sfnv "${PWD}/.gnupg" "${HOME}/.gnupg"

