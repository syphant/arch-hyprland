# ==============================
#  Basic Zsh Configuration
# ==============================

# Use modern completion system
autoload -Uz compinit
compinit

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS     # Ignore duplicates
setopt HIST_IGNORE_SPACE        # Ignore commands starting with space
setopt HIST_VERIFY              # Don’t execute immediately after !expansion
setopt SHARE_HISTORY            # Share history across sessions

# Enable useful options
setopt AUTO_CD                  # `cd` by just typing directory name
setopt CORRECT                  # Spell correction for commands
setopt EXTENDED_GLOB            # Advanced globbing
setopt NO_BEEP                  # Disable terminal beep
setopt PROMPT_SUBST             # Allow variable expansion in prompt

# ==============================
#  Prompt (using colors)
# ==============================

autoload -U colors && colors
PROMPT='%{$fg[cyan]%}%n%{$reset_color%}@%{$fg[magenta]%}%m %{$fg[green]%}%~%{$reset_color%} $(git_prompt_info)
%{$fg[blue]%}❯%{$reset_color%} '

# Optional: Git branch info (simple version)
git_prompt_info() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -n $branch ]] && echo "($branch)"
}

# ==============================
#  Aliases
# ==============================

alias ls="ls -alh --color=always"
alias up="yay -Syu"
alias in="yay -S"
alias un="yay -Rns"
alias grep='grep --color=auto'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push origin main'
alias gpl='git pull'

gacp() {
  git add .
  git commit -m "$*"
  branch=$(git rev-parse --abbrev-ref HEAD)
  git push origin "$branch"
}


# ==============================
#  Environment
# ==============================

export EDITOR="nano"
export VISUAL="code --wait"
export PAGER="less"
export LESS="-R"
export LANG="en_US.UTF-8"

# ==============================
#  Zinit Plugin Manager
# ==============================

if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
  mkdir -p ~/.zinit/bin
  git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
fi

source ~/.zinit/bin/zinit.zsh

# Example plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

# ==============================
#  Path
# ==============================

export PATH="$HOME/bin:/usr/local/bin:$PATH"

# ==============================
#  Keybinds
# ==============================

# Fix Home/End
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line

# Fix Page Up/Down to scroll through history
bindkey "\e[5~" history-beginning-search-backward
bindkey "\e[6~" history-beginning-search-forward

# ==============================
#  Terminal title (optional)
# ==============================

precmd() { print -Pn "\e]0;%n@%m: %~\a" }

# ==============================
#  Source local overrides
# ==============================

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
