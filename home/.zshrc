# -------------------------
# History
# -------------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# -------------------------
# Autocompletion
# -------------------------
fpath+=~/.zfunc
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select

# -------------------------
# PATH and environment
# -------------------------
export PATH="$PATH:/home/samin/.local/bin"
export GOPATH="$HOME/lib/go"
export PATH="$PATH:$GOPATH/bin"

export FZF_DEFAULT_OPTS="--height 40% --reverse --border"
export FZF_CTRL_R_OPTS="--height 40%"
export FZF_CTRL_T_OPTS="--height 60%"
export FZF_ALT_C_OPTS="--height 60% --preview 'exa --tree --icons --level=1 --color=always {}'"

export EDITOR=nvim

# -------------------------
# Lazy-load NVM
# -------------------------
export NVM_DIR="$HOME/.nvm"

nvm_load() {
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        source "$NVM_DIR/nvm.sh"
        source "$NVM_DIR/bash_completion" 2>/dev/null
        echo "NVM loaded"
    else
        echo "NVM not found in $NVM_DIR"
    fi
}

# -------------------------
# FZF
# -------------------------
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh

# -------------------------
# Key bindings
# -------------------------
zmodload -i zsh/complist
bindkey '^[[A' up-line-or-history
bindkey '^[[B' down-line-or-history
bindkey '^[[1;5C' forward-char
bindkey '^[[1;5D' backward-char

# -------------------------
# Aliases
# -------------------------
alias ls='exa --long --git'
alias rm='rm -i'
alias grep='rg'

# -------------------------
# Starship prompt
# -------------------------
eval "$(starship init zsh)"
