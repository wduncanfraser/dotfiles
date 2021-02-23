#!/bin/bash
set -e
set -o pipefail

# Script for setting up Debian 11 laptop, VM, or WSL from a minimal install

export DEBIAN_FRONTEND=noninteractive

# Choose a user account to use for this installation
get_user() {
  if [[ -z "${TARGET_USER-}" ]]; then
    mapfile -t options < <(find /home/* -maxdepth 0 -printf "%f\\n" -type d)
    # if there is only one option just use that user
    if [ "${#options[@]}" -eq "1" ]; then
      readonly TARGET_USER="${options[0]}"
      echo "Using user account: ${TARGET_USER}"
      return
    fi

    # iterate through the user options and print them
    PS3='command -v user account should be used? '

    select opt in "${options[@]}"; do
      readonly TARGET_USER=$opt
      break
    done
  fi
}

check_is_sudo() {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit
  fi
}

setup_debian_sources() {
  apt update || true

  apt install -y \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    --no-install-recommends

  tee /etc/apt/sources.list << EOF
deb https://deb.debian.org/debian/ bullseye main contrib non-free
deb-src https://deb.debian.org/debian/ bullseye main contrib non-free

deb https://security.debian.org/debian-security bullseye-security main contrib non-free
deb-src https://security.debian.org/debian-security bullseye-security main contrib non-free
EOF
}

base() {
  apt update || true
  apt -y upgrade

  apt install -y \
    apparmor \
    apt-listchanges \
    adduser \
    automake \
    bc \
    build-essential \
    bzip2 \
    ca-certificates \
    coreutils \
    cmake \
    curl \
    direnv \
    dnsutils \
    file \
    findutils \
    fish \
    gawk \
    g++-multilib \
    gcc-multilib \
    git \
    git-extras \
    gnupg \
    gpg-agent \
    grep \
    gzip \
    hostname \
    htop \
    jq \
    less \
    libc6-dev \
    lsof \
    make \
    manpages \
    mount \
    ncurses-term \
    neovim \
    openssh-client \
    pinentry-curses \
    pkg-config \
    psmisc \
    ranger \
    shellcheck \
    silversearcher-ag \
    strace \
    sudo \
    sysstat \
    systemd \
    tar \
    traceroute \
    tree \
    tzdata \
    unrar \
    unzip \
    wget \
    xz-utils \
    zip \
    --no-install-recommends

  setup_sudo
  set_shell

  apt autoremove -y
  apt autoclean -y
  apt clean -y
}

setup_sudo() {
  adduser "$TARGET_USER" sudo

  gpasswd -a "$TARGET_USER" systemd-journal
  gpasswd -a "$TARGET_USER" systemd-network
}

set_shell() {
  chsh --shell /usr/bin/fish "$TARGET_USER"
}

install_physical() {
  local system=$1
  local pkgs=( acpi firmware-linux fwupd fwupdate lm-sensors )

  case $system in
		"amd")
			pkgs+=( amd64-microcode )
			;;
		"intel")
			pkgs+=( intel-microcode firmware-sof-signed )
			;;
		*)
			echo "You need to specify whether it's an intel or amd cpu"
			exit 1
			;;
	esac

  apt update || true
  apt -y upgrade

  apt install -y "${pkgs[@]}" --no-install-recommends
}

install_graphics() {
  local system=$1
  local pkgs=( mesa-utils xwayland )

	case $system in
		"intel")
			pkgs+=( mesa-vulkan-drivers vulkan-tools )
			;;
		"vmware")
			pkgs+=( open-vm-tools )
			;;
		*)
			echo "You need to specify whether it's intel or vmware gpu"
			exit 1
			;;
	esac

  apt update || true
  apt -y upgrade

  apt install -y "${pkgs[@]}" --no-install-recommends
}

install_wm() {
  sudo apt update || true

  sudo apt install -y \
    sway \
    swaylock \
    swayidle \
    sway-backgrounds \
    adwaita-icon-theme \
    bluez \
    bluez-firmware \
    brightness-udev \
    brightnessctl \
    clipman \
    fonts-font-awesome \
    fonts-hack \
    fonts-liberation2 \
    fonts-lmodern \
    fonts-noto-color-emoji \
    fonts-stix \
    fonts-symbola \
    foot \
    gnome-themes-standard \
    grimshot \
    imv \
    libgtk-3-bin \
    libnotify-bin \
    mako-notifier \
    mpv \
    neofetch \
    network-manager \
    pinentry-gnome3 \
    playerctl \
    poppler-data \
    pulseaudio \
    pulseaudio-module-bluetooth \
    pulsemixer \
    rofi \
    waybar \
    wev \
    wl-clipboard \
    xdg-utils \
    zathura \
    --no-install-recommends

  # start and enable pulseaudio
  systemctl --user daemon-reload
  systemctl --user enable pulseaudio.service
  systemctl --user enable pulseaudio.socket
  systemctl --user start pulseaudio.service
}

install_rust() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

install_haskell() {
  sudo apt update || true

  sudo apt install -y \
    libffi-dev \
    libffi7 \
    libgmp-dev \
    libgmp10 \
    libncurses-dev \
    libncurses5 \
    libtinfo5 \
    --no-install-recommends

  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
}

install_golang() {
  export GO_VERSION
  GO_VERSION=$(curl -sSL "https://golang.org/VERSION?m=text")
  export GO_SRC=/usr/local/go

  # if we are passing the version
  if [[ -n "$1" ]]; then
    GO_VERSION=$1
  fi

  # purge old src
  if [[ -d "$GO_SRC" ]]; then
    sudo rm -rf "$GO_SRC"
    sudo rm -rf "$GOPATH"
  fi

  GO_VERSION=${GO_VERSION#go}

  kernel=$(uname -s | tr '[:upper:]' '[:lower:]')
  curl -sSL "https://golang.org/dl/go${GO_VERSION}.${kernel}-amd64.tar.gz" | sudo tar -v -C /usr/local -xz
}

install_node() {
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -

  # Replace with the branch of Node.js or io.js you want to install: node_6.x, node_8.x, etc...
  VERSION=node_14.x
  # The below command will set this correctly, but if lsb_release isn't available, you can set it manually:
  # - For Debian distributions: jessie, sid, etc...
  # - For Ubuntu distributions: xenial, bionic, etc...
  # - For Debian or Ubuntu derived distributions your best option is to use the codename corresponding to the upstream release your distribution is based off. This is an advanced scenario and unsupported if your distribution is not listed as supported per earlier in this README.
  DISTRO="$(lsb_release -s -c)"

  sudo tee /etc/apt/sources.list.d/nodesource.list << EOF
deb https://deb.nodesource.com/$VERSION $DISTRO main
deb-src https://deb.nodesource.com/$VERSION $DISTRO main
EOF

  sudo apt update || true
  sudo apt install -y \
    nodejs \
    --no-install-recommends
}

install_firefox() {
  sudo apt update || true

  sudo apt install -y \
    libdbus-glib-1-2 \
    libgtk-3-0 \
    --no-install-recommends

  firefox_path=/opt/firefox

  # purge old src
  if [[ -d "$firefox_path" ]]; then
    sudo rm -rf "$firefox_path"
  fi

  curl -fsSL https://download-installer.cdn.mozilla.net/pub/firefox/releases/85.0.2/linux-x86_64/en-US/firefox-85.0.2.tar.bz2 | sudo tar -v -C /opt -xj

  sudo tee /usr/share/applications/firefox-stable.desktop << EOF
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=env MOZ_ENABLE_WAYLAND=1 /opt/firefox/firefox %u
Terminal=false
Type=Application
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF

  sudo ln -svf /opt/firefox/firefox /usr/local/bin/firefox
  sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/firefox/firefox 200 && sudo update-alternatives --set x-www-browser /opt/firefox/firefox
}

install_vscode() {
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

  sudo apt update || true
  sudo apt install -y \
    code \
    --no-install-recommends
}

install_nvim() {
  sudo apt update || true
  sudo apt install -y \
    neovim \
    --no-install-recommends

  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}

usage() {
  echo -e "install.sh\\n  This script installs my basic setup for a debian laptop, wsl, or vm\\n"
  echo "Usage:"
  echo "  base                                - setup sources & install base pkgs used in all setups"
  echo "  physical {amd, intel}               - setup firmware, etc. Things we need on a physical machine, but not VM/WSL"
  echo "  graphics {intel, vmware}            - install graphics drivers"
  echo "  wm                                  - install window manager/desktop pkgs"
  echo "  rust                                - install rust"
  echo "  haskell                             - install haskell"
  echo "  golang                              - install golang"
  echo "  node                                - install node"
  echo "  firefox                             - install firefox current from tar"
  echo "  vscode                              - install vscode"
  echo "  nvim                                - install nvim and config"
}

main() {
  local cmd=$1

  if [[ -z "$cmd" ]]; then
    usage
    exit 1
  fi

  case $cmd in
    "base")
      check_is_sudo
      get_user
      setup_debian_sources
      base
      ;;
    "physical")
      check_is_sudo
      install_physical "$2"
      ;;
    "graphics")
      check_is_sudo
      install_graphics "$2"
      ;;
    "wm")
      install_wm
      ;;
    "rust")
      install_rust
      ;;
    "haskell")
      install_haskell
      ;;
    "golang")
      install_golang "$2"
      ;;
    "node")
      install_node
      ;;
    "firefox")
      install_firefox
      ;;
    "vscode")
      install_vscode
      ;;
    "nvim")
      install_nvim
      ;;
    *)
      usage
      ;;
    esac
}

main "$@"
