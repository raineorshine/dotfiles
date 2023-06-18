# .zhrc
# NOTE: This file should only contain commands that do not work in a bash environment. Prefer .bashrc.
# This is loaded whenever an interactive shell is opened.
# .bashrc and .zshrc can contain aliases, functions, and most anything except environment variables.

source ~/.bashrc

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
