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

deb https://deb.debian.org/debian/ bullseye-backports main contrib non-free

deb [allow-insecure=yes] https://discovery-deb.nyc3.digitaloceanspaces.com/debian bullseye-bp main
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
    fuse \
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
    tmux \
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
  local pkgs=( acpi firmware-linux fwupd fwupdate lm-sensors upower )

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
      pkgs+=( mesa-vulkan-drivers vulkan-tools intel-media-va-driver-non-free  )
      ;;
    "optimus")
      pkgs+=( bumblebee-nvidia bbswitch-dkms primus-nvidia primus-vk-nvidia linux-headers-generic )
      ;;
    "vmware")
      pkgs+=( open-vm-tools )
      ;;
    *)
      echo "You need to specify whether it's intel, optimus, or vmware gpu"
      exit 1
      ;;
  esac

  apt update || true
  apt -y upgrade

  apt install -y --allow-unauthenticated "${pkgs[@]}" --no-install-recommends
}

install_wm() {
  sudo apt update || true

  sudo apt install -y --allow-unauthenticated \
    sway \
    swayidle \
    swaylock \
    sway-backgrounds \
    adwaita-icon-theme \
    blueman \
    bluez \
    bluez-firmware \
    brightness-udev \
    brightnessctl \
    clipman \
    fonts-droid-fallback \
    fonts-font-awesome \
    fonts-hack \
    fonts-jetbrains-mono \
    fonts-liberation2 \
    fonts-lmodern \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    fonts-noto-mono \
    fonts-stix \
    fonts-symbola \
    foot \
    fuse \
    gir1.2-gtksource-4 \
    gnome-keyring \
    gnome-themes-standard \
    gnome-sushi \
    grimshot \
    gvfs-backends \
    imv \
    kanshi \
    libgdk-pixbuf2.0-bin \
    libgtk-3-bin \
    libnotify-bin \
    libsixel-bin \
    libspa-0.2-bluetooth \
    mako-notifier \
    mpv \
    nautilus \
    neofetch \
    network-manager \
    network-manager-gnome \
    pinentry-gnome3 \
    pipewire \
    pipewire-audio-client-libraries \
    pipewire-pulse \
    playerctl \
    poppler-data \
    pulseaudio-utils \
    pulsemixer \
    remmina \
    remmina-plugin-rdp \
    remmina-plugin-vnc \
    remmina-plugin-secret \
    seahorse \
    seahorse-nautilus \
    usbmuxd \
    waybar \
    wev \
    wireplumber \
    wl-clipboard \
    wofi \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal-wlr \
    xdg-utils \
    zathura \
    --no-install-recommends

  # https://wiki.debian.org/PipeWire#Debian_Testing.2FUnstablehttps://wiki.debian.org/PipeWire#Debian_Testing.2FUnstable
  # Setup Pipewire for ALSA
  sudo cp /usr/share/doc/pipewire/examples/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/

  # start and enable pipewire
  systemctl --user daemon-reload
  systemctl --user --now enable pipewire pipewire-pulse wireplumber.service
}

install_docker() {
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

  sudo apt update || true
  sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin \
    pigz \
    --no-install-recommends
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
    --no-install-recommends

  # Project deps (XZ, SHA1, etc)
  sudo apt install -y \
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

install_dotnet() {
  TEMP_DEB="$(mktemp)"
  wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O "$TEMP_DEB"
  sudo dpkg -i "$TEMP_DEB"
  rm -f "$TEMP_DEB"

  sudo apt update || true
  sudo apt install -y \
    dotnet-sdk-6.0 \
    --no-install-recommends
}

install_firefox() {
  sudo apt update || true

  sudo apt install -y \
    libdbus-glib-1-2 \
    libgtk-3-0 \
    libxtst6 \
    --no-install-recommends

  firefox_path=/opt/firefox
  firefox_version="104.0.1"

  # if we are passing the version
  if [[ -n "$1" ]]; then
    firefox_version=$1
  fi

  # purge old src
  if [[ -d "$firefox_path" ]]; then
    sudo rm -rf "$firefox_path"
  fi

  curl -fsSL "https://download-installer.cdn.mozilla.net/pub/firefox/releases/$firefox_version/linux-x86_64/en-US/firefox-$firefox_version.tar.bz2" | sudo tar -v -C /opt -xj

  sudo mkdir -p /usr/local/share/applications
  sudo tee /usr/local/share/applications/firefox-stable.desktop << EOF
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

install_code() {
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg

  sudo tee /etc/apt/sources.list.d/vscode.list << EOF
deb [arch=amd64,arm64,armhf] http://packages.microsoft.com/repos/code stable main
EOF

  sudo apt update || true
  sudo apt install -y \
    code \
    --no-install-recommends

  mkdir -p "$HOME/local/bin"
  tee "$HOME/.local/bin/code" << 'EOF'
#!/bin/sh
exec /usr/bin/code --ozone-platform-hint=auto "$@"
EOF
  chmod +x "$HOME/.local/bin/code"

  mkdir -p "$HOME/.local/share/applications"
  tee "$HOME/.local/share/applications/code.desktop" << EOF
[Desktop Entry]
Name=Visual Studio Code
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=/usr/share/code/code --ozone-platform-hint=auto --unity-launch %F
Icon=com.visualstudio.code
Type=Application
StartupNotify=false
StartupWMClass=Code
Categories=TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;application/x-code-workspace;
Actions=new-empty-window;
Keywords=vscode;

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=/usr/share/code/code --ozone-platform-hint=auto --new-window %F
Icon=com.visualstudio.code
EOF
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

usage() {
  echo -e "install.sh\\n  This script installs my basic setup for a debian laptop, wsl, or vm\\n"
  echo "Usage:"
  echo "  base                                - setup sources & install base pkgs used in all setups"
  echo "  physical {amd, intel}               - setup firmware, etc. Things we need on a physical machine, but not VM/WSL"
  echo "  graphics {intel, optimus, vmware}   - install graphics drivers"
  echo "  wm                                  - install window manager/desktop pkgs"
  echo "  docker                              - install docker from official repos"
  echo "  rust                                - install rust"
  echo "  haskell                             - install haskell"
  echo "  golang {version (optional)}         - install golang"
  echo "  node                                - install node"
  echo "  dotnet                              - install dotnet SDK"
  echo "  chromium                            - install chromium"
  echo "  firefox {version (optional)}        - install firefox current from tar"
  echo "  code                                - install vscode"
  echo "  nvim                                - install nvim and config"
  echo "  spotify                             - install spotifyd and spotify-tui"
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
    "docker")
      install_docker
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
    "dotnet")
      install_dotnet
      ;;
    "chromium")
      install_chromium
      ;;
    "firefox")
      install_firefox "$2"
      ;;
    "code")
      install_code
      ;;
    "nvim")
      install_nvim
      ;;
    "spotify")
      install_spotify
      ;;
    *)
      usage
      ;;
    esac
}

main "$@"
