set fish_greeting

# Go env
set -x GOPATH $HOME/dev/go
set -gx PATH /usr/local/go/bin $PATH

# Rust env
set -gx PATH $HOME/.cargo/bin $PATH

# ghcup-env
set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME
test -f $HOME/.ghcup/env ; and set -gx PATH $HOME/.cabal/bin $HOME/.ghcup/bin $PATH

# Defaults
set -gx EDITOR nvim
set -gx BROWSER firefox

# GNUPG
set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)

# Direnv
eval (direnv hook fish)

if status --is-interactive
    set -x GPG_TTY (tty)
end