export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# aliases
which rg > /dev/null && alias grep="rg"
which nvim > /dev/null && \
    alias vim="nvim" && \
    alias vi="nvim" && \
    alias v="nvim" && \
    alias lc="nvim leetcode.nvim"
which exa > /dev/null && alias ls="exa"
which python3 > /dev/null && alias p3="python3"
alias gs="git status"
alias gc="git commit"
alias gp="git pull"
alias gP="git push"

# starship prompt
eval "$(starship init zsh)"
