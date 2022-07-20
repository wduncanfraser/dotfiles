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

deb http://deb.debian.org/debian/ bullseye-backports main contrib non-free
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
    genius \
    git/bullseye-backports \
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
    net-tools \
    openssh-client \
    pass \
    pinentry-curses \
    pkg-config \
    psmisc \
    pv \
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
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    fonts-stix \
    fonts-symbola \
    foot \
    fuse \
    gnome-keyring \
    gnome-themes-standard \
    grimshot \
    imv \
    kanshi \
    libgtk-3-bin \
    libnotify-bin \
    libsixel-bin \
    mako-notifier \
    mpv \
    neofetch \
    network-manager \
    network-manager-gnome \
    pinentry-gnome3 \
    playerctl \
    poppler-data \
    pulseaudio \
    pulseaudio-module-bluetooth \
    pulsemixer \
    remmina \
    remmina-plugin-rdp \
    remmina-plugin-vnc \
    remmina-plugin-secret \
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

  rustup component add rust-src
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
    # Project deps (XZ, SHA1, etc)
    liblzma-dev \
    zlib1g-dev \
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
  VERSION=node_16.x
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
  firefox_version="102.0.1"

  # if we are passing the version
  if [[ -n "$1" ]]; then
    firefox_version=$1
  fi

  # purge old src
  if [[ -d "$firefox_path" ]]; then
    sudo rm -rf "$firefox_path"
  fi

  curl -fsSL "https://download-installer.cdn.mozilla.net/pub/firefox/releases/$firefox_version/linux-x86_64/en-US/firefox-$firefox_version.tar.bz2" | sudo tar -v -C /opt -xj

  sudo tee /usr/share/applications/firefox-stable.desktop << EOF
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=env MOZ_ENABLE_WAYLAND=1 $firefox_path/firefox %u
Terminal=false
Type=Application
Icon=$firefox_path/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF

  sudo ln -svf "$firefox_path/firefox" /usr/local/bin/firefox
  sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser $firefox_path/firefox 200 && sudo update-alternatives --set x-www-browser $firefox_path/firefox
}

install_chromium() {
  sudo apt update || true

  sudo apt install -y \
    chromium \
    chromium-sandbox \
    --no-install-recommends
}

install_nvim() {
  nvim_version="0.7.2"
  nvim_path=/opt/nvim
  nvim_image=$nvim_path/nvim.appimage

  # Purge old versions
  if [[ -d "$nvim_path" ]]; then
    sudo rm -rf "$nvim_path"
  fi

  sudo mkdir -p $nvim_path

  curl -fsSL "https://github.com/neovim/neovim/releases/download/v$nvim_version/nvim.appimage" | sudo dd of=$nvim_image

  sudo chmod +x $nvim_image

  sudo ln -svf $nvim_image /usr/local/bin/nvim
  sudo ln -svf $nvim_image /usr/local/bin/vim

  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}

install_spotify() {
  spotifyd_version="0.3.3"
  spotifytui_version="0.25.0"

  if [[ -d /usr/local/bin/spotifyd ]]; then
    sudo rm -f /usr/local/bin/spotifyd
  fi

  curl -fsSL "https://github.com/Spotifyd/spotifyd/releases/download/v$spotifyd_version/spotifyd-linux-default.tar.gz" | sudo tar -v -C /usr/local/bin -xz

  if [[ -d /usr/local/bin/spt ]]; then
    sudo rm -f /usr/local/bin/spt
  fi

  curl -fsSL "https://github.com/Rigellute/spotify-tui/releases/download/v$spotifytui_version/spotify-tui-linux.tar.gz" | sudo tar -v -C /usr/local/bin -xz

  systemctl --user enable spotifyd.service
  systemctl --user start spotifyd.service
}

install_rider() {
  rider_version="2022.1.2"
  rider_path="JetBrains Rider-${rider_version}"

  # purge old src
  if [[ -d "$rider_path" ]]; then
    sudo rm -rf "$rider_path"
  fi

  curl -fsSL "https://download.jetbrains.com/rider/JetBrains.Rider-${rider_version}.tar.gz" | sudo tar -v -C /opt -xz

  # Fix fish shell loading https://github.com/fish-shell/fish-shell/issues/3988:q
  sudo ln -s ~/.config/fish/fish_variables "/opt/${rider_path}/plugins/terminal/fish/fish_variables"

  sudo tee /usr/share/applications/jetbrains-rider.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=JetBrains Rider
Icon=/opt/${rider_path}/bin/rider.svg
Exec=env _JAVA_AWT_WM_NONREPARENTING=1 "/opt/${rider_path}/bin/rider.sh" %f
Comment=A cross-platform IDE for .NET
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-rider
StartupNotify=true
EOF
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
  echo "  golang {version (optional)}         - install golang"
  echo "  node                                - install node"
  echo "  chromium                            - install chromium"
  echo "  firefox {version (optional)}        - install firefox current from tar"
  echo "  nvim                                - install nvim and config"
  echo "  spotify                             - install spotifyd and spotify-tui"
  echo "  rider                               - install rider"
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
      install_spotify
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
    "chromium")
      install_chromium
      ;;
    "firefox")
      install_firefox "$2"
      ;;
    "nvim")
      install_nvim
      ;;
    "spotify")
      install_spotify
      ;;
    "rider")
      install_rider
      ;;
    *)
      usage
      ;;
    esac
}

main "$@"
