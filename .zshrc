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
export PATH="$PATH:$GOPATH/bin"
export FZF_DEFAULT_OPTS="--height 40% --reverse --border"
export FZF_CTRL_R_OPTS="--height 40% "
export FZF_CTRL_T_OPTS="--height 60% "
export FZF_ALT_C_OPTS="--height 60% --preview 'exa --tree --icons --level=1 --color=always {}'"



source /usr/share/fzf/key-bindings.zsh
# source /usr/share/fzf/completion.zsh

# Use arrow keys to navigate the menu
zmodload -i zsh/complist
bindkey '^[[A' up-line-or-history
bindkey '^[[B' down-line-or-history
bindkey '^[[1;5C' forward-char
bindkey '^[[1;5D' backward-char

# Alias
alias ls='exa --long --git'
alias rm -rf='rm -i'


eval "$(starship init zsh)"




