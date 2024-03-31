# ZSH History Configuration

# History Configuration
setopt extended_history        # Write the history file in the ':start:elapsed;command' format.
setopt hist_ignore_all_dups    # Delete an old recorded event if a new event is a duplicate.
setopt hist_ignore_space       # Do not record an event starting with a space.
setopt hist_reduce_blanks      # Remove extra blanks from commands added to the history list.
setopt inc_append_history      # Write to the history file immediately, not when the shell exits.
setopt share_history           # Share history between sessions

# Session History
HISTSIZE=10000
# Persisted History
SAVEHIST=100000
HISTFILE="$ZDATADIR/zsh_history"

# History aliases.
alias hist='fc -li'
