# Created by newuser for 5.9
# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Enable autocompletion
autoload -Uz compinit
compinit

# Use menu select for autocompletion
zstyle ':completion:*' menu select

#path
export PATH="$PATH:/home/samin/.local/bin"
export GOPATH="$HOME/lib/go"

# Use arrow keys to navigate the menu
zmodload -i zsh/complist
bindkey '^[[A' up-line-or-history
bindkey '^[[B' down-line-or-history
bindkey '^[[1;5C' forward-char
bindkey '^[[1;5D' backward-char

# Alias
alias ls='exa --long'
alias ns='echo '\''-n canvas-starhub-sg-cmp-int-shcmp-dev-01'\'''

eval "$(starship init zsh)"
