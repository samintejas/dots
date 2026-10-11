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

export FZF_DEFAULT_OPTS="--height 40% --reverse --border --color=bg:#060606,bg+:#0f0f0f,fg:#b4b4b4,fg+:#f5f5f5,hl:#ef9cd8,hl+:#ef9cd8,info:#9c9c9c,prompt:#ef9cd8,pointer:#ef9cd8,marker:#a6e3a1,spinner:#9c9c9c,header:#9c9c9c,border:#383838,gutter:#060606"
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
alias ls='eza --long --git'
alias rm='rm -i'
alias grep='rg'

# -------------------------
# Plugins
# -------------------------
#[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# -------------------------
# Starship prompt
# -------------------------
eval "$(starship init zsh)"

export CHROME_REMOTE_DEBUGGING_URL="http://localhost:9222"
export PATH="$HOME/.cargo/bin:$PATH"

# opencode
export PATH=/home/samin/.opencode/bin:$PATH



# -------------------------
# GitLab (Vonnue)
# -------------------------
export GITLAB_URL="https://gitlab.vonnue.dev"
export GITLAB_HOST="gitlab.vonnue.dev"
export GITLAB_API_URL="$GITLAB_URL/api/v4"
export GL_HOST="$GITLAB_HOST"
export CI_SERVER_URL="$GITLAB_URL"
export DESIGN_SYSTEM_URL="https://vonnue.pages.gitlab.vonnue.dev/engineering/design-system/"
# Personal access token: put it (only the token) in ~/.config/gitlab/token, chmod 600
[[ -r ~/.config/gitlab/token ]] && export GITLAB_TOKEN="$(<~/.config/gitlab/token)" && export GITLAB_PRIVATE_TOKEN="$GITLAB_TOKEN"

# v-orch modernisation control repo (pauzible). env/.env is the single source of truth; secrets.env is NOT exported.
export MC_CONTROL_ROOT="$HOME/repo/vonnue/vonnue-modernization-toolkit/v-orch-cp"
[[ -r "$MC_CONTROL_ROOT/env/.env" ]] && { set -a; source "$MC_CONTROL_ROOT/env/.env"; set +a; }
