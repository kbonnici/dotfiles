export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH:$HOME/scripts

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
which eza > /dev/null && alias ls="eza"
which python3 > /dev/null && alias p3="python3"
alias gs="git status"
alias gc="git commit"
alias gp="git pull"
alias gP="git push"
alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'


# starship prompt
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"

source <(fzf --zsh)
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

export FZF_DEFAULT_OPTS=" \
--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
--color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"

export EDITOR="nvim"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

[ -f ~/.zsh_functions ] && source ~/.zsh_functions

bindkey -s '^p' 'find_files\n'
