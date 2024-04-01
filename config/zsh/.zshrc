#!/usr/bin/env zsh

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

## Load confg.d
source "$ZDOTDIR/conf.d/history.zsh"
source "$ZDOTDIR/conf.d/functions.zsh"
source "$ZDOTDIR/conf.d/completion.zsh"
source "$ZDOTDIR/conf.d/plugins.zsh"

## Env
# Defaults
export EDITOR="nvim"
export BROWSER="firefox"

# Firefox Configuration
export MOZ_DBUS_REMOTE=1

# Local bin
export PATH="$PATH:$HOME/.local/bin"

# Go Env
export GOPATH="$HOME/dev/go"
export PATH="$PATH:/usr/local/go/bin"

# Rust env
export PATH="$PATH:$HOME/.cargo/bin"

# Deno env
export DENO_INSTALL="$HOME/.deno"
export PATH="$PATH:$DENO_INSTALL/bin"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# ghcup-env
[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env"

# GNUPG
# TODO: Use gpg-agent for SSH on MacOS
if ! [[ "$OSTYPE" =~ ^darwin ]]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi
if [[ -o interactive ]]; then
  export GPG_TTY="$(tty)"
fi

# NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

## Starship
eval "$(starship init zsh)"

# Direnv
eval "$(direnv hook zsh)"

