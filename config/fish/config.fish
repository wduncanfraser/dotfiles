set fish_greeting

# Go env
set -x GOPATH $HOME/dev/go
set -gx PATH /usr/local/go/bin $PATH

# Rust env
set -gx PATH $HOME/.cargo/bin $PATH

# Deno env
set -x DENO_INSTALL $HOME/.deno
set -gx PATH $DENO_INSTALL/bin $PATH

# ghcup-env
set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME
test -f $HOME/.ghcup/env ; and set -gx PATH $HOME/.cabal/bin $HOME/.ghcup/bin $PATH

# local
set -gx PATH $HOME/.local/bin $PATH

# Defaults
set -gx EDITOR nvim
set -gx BROWSER firefox

# Firefox config
set -gx MOZ_DBUS_REMOTE 1

# GNUPG
set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)

# Direnv
eval (direnv hook fish)

if status --is-interactive
    set -x GPG_TTY (tty)
end

# Prompt features
set --universal pure_separate_prompt_on_error true
set --universal pure_show_subsecond_command_duration true
set --universal pure_threshold_command_duration 1
