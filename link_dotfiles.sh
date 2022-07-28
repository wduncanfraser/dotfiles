#!/bin/bash
set -e
set -o pipefail

base() {
  config_dirs=("fish"  "nvim")

  for val in ${config_dirs[*]}; do
    ln -sfnv "${PWD}/config/${val}" "${HOME}/.config/${val}"
  done

  mkdir -p "${HOME}/.gnupg"
  ln -sfnv "${PWD}/.gnupg/gpg-agent.conf" "${HOME}/.gnupg/gpg-agent.conf"
  #for file in $(find "${PWD}/.gnupg" -mindepth 1); do
	#	f=$(basename ${file})
	#	ln -sfnv "${file}" "${HOME}/.gnupg/${f}"
	#done

  ln -sfnv "${PWD}/.tmux.conf" "${HOME}/.tmux.conf"
}

wm() {
  config_dirs=("fontconfig"  "foot" "gtk-3.0" "rofi" "spotifyd" "sway" "swaylock" "systemd" "waybar")

  for val in ${config_dirs[*]}; do
    ln -sfnv "${PWD}/config/${val}" "${HOME}/.config/${val}"
  done

  # Mako doesn't like symlinks
  mkdir -p "${HOME}/.config/mako"
  ln -fv "${PWD}/config/mako/config" "${HOME}/.config/mako/config"
}

mac() {
  config_dirs=("alacritty" "fish"  "nvim")

  for val in ${config_dirs[*]}; do
    ln -sfnv "${PWD}/config/${val}" "${HOME}/.config/${val}"
  done

  #mkdir -p "${HOME}/.gnupg"
  #ln -sfnv "${PWD}/.gnupg/gpg-agent.conf" "${HOME}/.gnupg/gpg-agent.conf"

  ln -sfnv "${PWD}/.tmux.conf" "${HOME}/.tmux.conf"
}

usage() {
  echo -e "link_dotfiles.sh\\n  This script links dotfiles into place\\n"
  echo "Usage:"
  echo "  base                                - link dotfiles used everywhere (fish, nvim, gnupg, etc)"
  echo "  wm                                  - link dotfiles used in a GUI/WM environment"
  echo "  mac                                 - link dotfiles used in macOS"
}

main() {
  local cmd=$1

  if [[ -z "$cmd" ]]; then
    usage
    exit 1
  fi

  case $cmd in
    "base")
      base
      ;;
    "wm")
      base
      wm
      ;;
    "mac")
      mac
      ;;
    *)
      usage
      ;;
    esac
}

main "$@"

