# .zhrc
# NOTE: This file should only contain commands that do not work in a bash environment. Prefer .bashrc.
# This is loaded whenever an interactive shell is opened.
# .bashrc and .zshrc can contain aliases, functions, and most anything except environment variables.

source ~/.bashrc

so() {
  source $dothome/.zshrc
}

alias git=hub

# project directory
p() {
  if [ $# -eq 0 ]; then n=10; else n="$1" fi
  pushd ~/projects &> /dev/null
  ls -AGFplht --color=always | grep -v .DS_Store | tail +2 | head -n "$n"
  echo ...
}

# git tab completion
autoload -Uz compinit && compinit

bindkey "\C-h" backward-char
# kills tab-completion!
# bindkey "\C-i" forward-char
bindkey "\C-b" backward-word
bindkey "\C-a" end-of-line

# doesn't work?
bindkey "\C-0" beginning-of-line
bindkey "\C-p" beginning-of-line

# display "✓" on right side if error code 0, otherwise display "✗"
RPROMPT="%(?.%F{green}✓%f.%F{red}✗%f)"

# strip rprompt checkmark
# useful for copying the shell output to a github issue
alias stripr=sed 's/\w*✓//'

# timestamp
# RPROMPT="%*"

# set window title to current working directory after returning from a command
precmd() { echo -ne "\e]1;${PWD##*/}\a" }

# lazy load nvm
# https://github.com/nvm-sh/nvm/issues/2724#issuecomment-1336537635
lazy_load_nvm() {
  unset -f node npm nvm
  export NVM_DIR=~/.nvm
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
}

node() {
  lazy_load_nvm
  node $@
}

npm() {
  lazy_load_nvm
  npm $@
}

nvm() {
  lazy_load_nvm
  nvm $@
}
