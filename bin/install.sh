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
deb https://deb.debian.org/debian/ trixie main contrib non-free-firmware non-free
deb-src https://deb.debian.org/debian/ trixie main contrib non-free-firmware non-free

deb https://security.debian.org/debian-security trixie-security main contrib non-free-firmware non-free
deb-src https://security.debian.org/debian-security trixie-security main contrib non-free-firmware non-free

deb https://deb.debian.org/debian/ trixie-backports main contrib non-free-firmware non-free
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
    fd-find \
    file \
    findutils \
    fuse3 \
    fzf \
    gawk \
    g++-multilib \
    gcc-multilib \
    genius \
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
    net-tools \
    openssh-client \
    pass \
    pinentry-curses \
    pkg-config \
    psmisc \
    pv \
    ranger \
    ripgrep \
    shellcheck \
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
    zsh \
    --no-install-recommends

  setup_sudo
  set_shell
  install_starship

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
  chsh --shell /usr/bin/zsh "$TARGET_USER"
}

install_starship() {
  curl -sS https://starship.rs/install.sh | sh
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
    "amd")
      pkgs+=( mesa-vulkan-drivers vulkan-tools mesa-va-drivers firmware-amd-graphics  )
      ;;
    "intel")
      pkgs+=( mesa-vulkan-drivers vulkan-tools intel-media-va-driver-non-free  )
      ;;
    "optimus")
      pkgs+=( nvidia-driver )
      ;;
    "vmware")
      pkgs+=( open-vm-tools )
      ;;
    *)
      echo "You need to specify whether it's amd, intel, optimus, or vmware gpu"
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
    gir1.2-gtksource-4 \
    gnome-calculator \
    gnome-keyring \
    gnome-themes-extra \
    gnome-sushi \
    gnome-weather \
    grimshot \
    gvfs-backends \
    imv \
    kanshi \
    libayatana-appindicator1 \
    libayatana-appindicator3-1 \
    libgdk-pixbuf2.0-bin \
    libgtk-3-bin \
    libnotify-bin \
    libpipewire-0.3-common \
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
    pipewire-alsa \
    pipewire-jack \
    pipewire-pulse \
    playerctl \
    poppler-data \
    pulseaudio-utils \
    pulsemixer \
    remmina \
    remmina-plugin-rdp \
    remmina-plugin-vnc \
    remmina-plugin-secret \
    rtkit \
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

  # start and enable pipewire
  systemctl --user daemon-reload
  systemctl --user --now enable pipewire pipewire-pulse wireplumber.service

  # Start and enable playerctld
  systemctl --user --now enable playerctld
}

install_mpd() {
  mpd_mpris_version="0.4.1"
  mpd_mpris_path="/usr/local/bin/mpd-mpris"

  sudo apt update || true
  sudo apt install -y \
    mpd \
    ymuse \
    --no-install-recommends

  if [[ -d $mpd_mpris_path ]]; then
    sudo rm -f $mpd_mpris_path
  fi

  curl -fsSL "https://github.com/natsukagami/mpd-mpris/releases/download/v${mpd_mpris_version}/mpd-mpris_${mpd_mpris_version}_linux_amd64.tar.gz" | sudo tar -v -C /usr/local/bin -xz mpd-mpris

  sudo chown root:root $mpd_mpris_path
  sudo chmod 0755 $mpd_mpris_path

  # Setup local dirs
  mkdir -p "$HOME/.local/state/mpd"

  # Start and enable services
  systemctl --user daemon-reload
  systemctl --user --now enable mpd mpd-mpris
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

install_kubectl() {
  version=$(curl -L -s https://dl.k8s.io/release/stable.txt)
  path="/usr/local/bin/kubectl"

  curl -fsSL "https://dl.k8s.io/release/${version}/bin/linux/amd64/kubectl" | sudo dd of=$path

  sudo chmod 0755 $path
  sudo chown root:root $path
}

# Languages/SDKs
install_deno() {
  # TODO: Specific version needed for nvim peek plugin
  curl -fsSL https://deno.land/install.sh | sh -s v1.33.1
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

install_golang() {
  export GO_VERSION
  GO_VERSION=$(curl -sSL "https://go.dev/VERSION?m=text" | head -1)
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
  curl -sSL "https://go.dev/dl/go${GO_VERSION}.${kernel}-amd64.tar.gz" | sudo tar -v -C /usr/local -xz
}

install_haskell() {
  sudo apt update || true

  sudo apt install -y \
    libffi-dev \
    libffi8 \
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

install_pnpm() {
  curl -fsSL https://get.pnpm.io/install.sh | sh -
}

install_rust() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

  rustup component add rust-src
}

install_sdkman() {
  curl -s "https://get.sdkman.io" | bash

  source "$HOME/.sdkman/bin/sdkman-init.sh"
}

# Editors
install_code() {
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg

  sudo tee /etc/apt/sources.list.d/vscode.list << EOF
deb [arch=amd64,arm64,armhf] http://packages.microsoft.com/repos/code stable main
EOF

  sudo apt update || true
  sudo apt install -y \
    code \
    --no-install-recommends

  mkdir -p "$HOME/.local/bin"
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
  nvim_version="0.11.3"
  nvim_path=/opt/nvim
  nvim_image=$nvim_path/nvim.appimage

  # Purge old versions
  if [[ -d "$nvim_path" ]]; then
    sudo rm -rf "$nvim_path"
  fi

  sudo mkdir -p $nvim_path

  curl -fsSL "https://github.com/neovim/neovim/releases/download/v$nvim_version/nvim-linux-x86_64.appimage" | sudo dd of=$nvim_image

  sudo chmod +x $nvim_image

  sudo ln -svf $nvim_image /usr/local/bin/nvim
  sudo ln -svf $nvim_image /usr/local/bin/vim

  # Install dependencies for plugins
  sudo apt update || true

  # Peek (Markdown preview)
  sudo apt install -y \
    libwebkit2gtk-4.0-37 \
    --no-install-recommends
}


# Web
install_chromium() {
  sudo apt update || true

  sudo apt install -y \
    chromium \
    chromium-sandbox \
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
  firefox_version="141.0.3"

  # if we are passing the version
  if [[ -n "$1" ]]; then
    firefox_version=$1
  fi

  # purge old src
  if [[ -d "$firefox_path" ]]; then
    sudo rm -rf "$firefox_path"
  fi

  curl -fsSL "https://download-installer.cdn.mozilla.net/pub/firefox/releases/$firefox_version/linux-x86_64/en-US/firefox-$firefox_version.tar.xz" | sudo tar -v -C /opt -xJ

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

install_spotify() {
  # Workaround for xdg-desktop-menu bug. xdg-desktop-menu: No writable system menu directory found.
  sudo mkdir -p /usr/share/desktop-directories

  curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
  echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

  sudo apt update || true
  sudo apt install -y \
    spotify-client \
    --no-install-recommends
}

usage() {
  echo -e "install.sh\\n  This script installs my basic setup for a debian laptop, wsl, or vm\\n"
  echo "Usage:"
  echo "  base                                    - setup sources & install base pkgs used in all setups"
  echo "  physical {amd, intel}                   - setup firmware, etc. Things we need on a physical machine, but not VM/WSL"
  echo "  graphics {amd, intel, optimus, vmware}  - install graphics drivers"
  echo "  wm                                      - install window manager/desktop pkgs"
  echo "  mpd                                     - install mpd/mpd"
  echo "  docker                                  - install docker from official repos"
  echo "  kubectl                                 - install kubectl"
  echo "(Languages/SDKs)"
  echo "  deno                                    - install deno"
  echo "  dotnet                                  - install dotnet SDK"
  echo "  golang {version (optional)}             - install golang"
  echo "  haskell                                 - install haskell"
  echo "  pnpm                                    - install pnpm - node"
  echo "  rust                                    - install rust"
  echo "  sdkman                                  - install sdkman (jdk)"
  echo "(Editors)"
  echo "  code                                    - install vscode"
  echo "  nvim                                    - install nvim and config"
  echo "(Web)"
  echo "  chromium                                - install chromium"
  echo "  firefox {version (optional)}            - install firefox current from tar"
  echo "  spotify                                 - install spotify"
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
    "mpd")
      install_mpd
      ;;
    "docker")
      install_docker
      ;;
    "kubectl")
      install_kubectl
      ;;
    # Languages/SDKs
    "deno")
      install_deno
      ;;
    "dotnet")
      install_dotnet
      ;;
    "golang")
      install_golang "$2"
      ;;
    "haskell")
      install_haskell
      ;;
    "pnpm")
      install_pnpm
      ;;
    "rust")
      install_rust
      ;;
    "sdkman")
      install_sdkman
      ;;
    # Editors
    "code")
      install_code
      ;;
    "nvim")
      install_nvim
      ;;
    # Web
    "chromium")
      install_chromium
      ;;
    "firefox")
      install_firefox "$2"
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
