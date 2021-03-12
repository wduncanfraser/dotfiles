#!/bin/bash
set -e
set -o pipefail

base() {
  config_dirs=("fish"  "nvim")

  for val in ${config_dirs[*]}; do
    ln -sfnv "${PWD}/config/${val}" "${HOME}/.config/${val}"
  done

  ln -sfnv "${PWD}/.gnupg" "${HOME}/.gnupg"
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

usage() {
  echo -e "link_dotfiles.sh\\n  This script links dotfiles into place\\n"
  echo "Usage:"
  echo "  base                                - link dotfiles used everywhere (fish, nvim, gnupg, etc)"
  echo "  wm                                  - link dotfiles used in a GUI/WM environment"
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
    *)
      usage
      ;;
    esac
}

main "$@"

