# .zhrc
# NOTE: This file should only contain commands that do not work in a bash environment. Prefer .bashrc.
# This is loaded whenever an interactive shell is opened.
# .bashrc and .zshrc can contain aliases, functions, and most anything except environment variables.

source ~/.bashrc

so() {
  source $dothome/.zshrc
}

alias git=hub
alias brave='open -a Brave\ Browser'
alias chrome='open -a Google\ Chrome'

# browse the home page of an npm module
nbro() {
  npm view "$@" homepage | xargs open
}

notify() {
  /usr/bin/osascript -e "display notification \"$*\" with title \"Notification\""
}

# icloud directory
ic() {
  pushd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Documents &> /dev/null
  ls
}

# project directory
p() {
  if [ $# -eq 0 ]; then n=10; else n="$1" fi
  pushd ~/projects &> /dev/null
  ls -AGFplht --color=always | grep -v .DS_Store | tail +2 | head -n "$n"
  echo ...
}

# Secure directory
s() {
  pushd ~/Documents/Secure &> /dev/null
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

#-------------------------#
# nvm
#-------------------------#

nvm_global_binaries() {

  # Look for global binaries
  local global_binary_paths="$(echo "$NVM_DIR"/v0*/bin/*(N) "$NVM_DIR"/versions/*/*/bin/*(N))"

  # If we have some, format them
  # This is slow, but still after than load_nvm
  if [[ -n "$global_binary_paths" ]]; then
    echo "$NVM_DIR"/v0*/bin/*(N) "$NVM_DIR"/versions/*/*/bin/*(N) |
      xargs -n 1 basename |
      sort |
      uniq
  fi
}

load_nvm() {
  [[ -z "$NVM_DIR" ]] && export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
}

# lazy load nvm
# Based on zsh-nvm: https://github.com/lukechilds/zsh-nvm/blob/745291dcf20686ec421935f1c3f8f3a2918dd106/zsh-nvm.plugin.zsh#L80
# Related issue: https://github.com/nvm-sh/nvm/issues/2724#issuecomment-1336537635
lazy_load_nvm() {

  [[ -z "$NVM_DIR" ]] && export NVM_DIR="$HOME/.nvm"

  # Get all global node module binaries including node
  local global_binaries
  global_binaries=($(nvm_global_binaries))
  global_binaries+=('nvm')

  # Remove any binaries that conflict with current aliases
  local cmds
  cmds=()
  local bin
  for bin in $global_binaries; do
    [[ "$(which $bin 2> /dev/null)" = "$bin: aliased to "* ]] || cmds+=($bin)
  done

  # Create function for each command
  local cmd
  for cmd in $cmds; do
    # When called, unset all lazy loaders, load nvm then run current command
    eval "$cmd(){
      unset -f $cmds > /dev/null 2>&1
      load_nvm
      $cmd \"\$@\"
    }"
  done
}

lazy_load_nvm

#-------------------------#
# dotfiles
#-------------------------#

# add, commit, and push to dotfiles repo
dm() {
  dir=$(pwd)
  cd "$dothome"

  # supply commit message as argument
  # or default to timestamp
  args="$@"
  msg=${args:="backup `date +%F-%T`"}

  so &&
  git add -A &&
  git commit -m "$msg"
  git push

  cd "$dir"
}

# add, amend, and force push to dotfiles repo
daforce() {
  dir=$(pwd)
  cd "$dothome"

  so &&
  git add -A &&
  git commit --amend --no-edit
  git push --force

  cd "$dir"
}

# open dotfiles repo
dbro() {
  open "https://github.com/raineorshine/dotfiles"
}

# change directory to ~/projects/dotfiles
dcs() {
  cs $dothome
}

# diff the dotfiles repo
# overrides unused /bin/dd
dd() {
  dir=$(pwd)
  cd "$dothome"

  git --no-pager diff --exit-code --color=always ||
  echo -e "\nRun 'dm' to commit dotfile changes"

  cd "$dir"
}

#-------------------------#
# Karabiner
#-------------------------#

# edit karabiner.json
kar() {
  kardiff
  $EDITOR ~/.config/karabiner/karabiner.json
}

# pushd to ~/.config/karabiner
kardir() {
  kardiff
  pushd ~/.config/karabiner
}

# diff karabiner-config
kardiff() {
  dir=$(pwd)
  cd ~/.config/karabiner
  git --no-pager diff
  cd "$dir"
}

# pull karabiner-config
karpull() {
  dir=$(pwd)
  cd ~/.config/karabiner
  git pull
  cd "$dir"
}

#-------------------------#
# gpg
#-------------------------#

alias gpg="gpg2 -o -"
alias pri="gpg -d ~/Google\ Drive/Finance/Accounts/private.json.asc | less"

# encrypt and pipe to stdout
gpge() {
  # requires "brew install gnupg"
  gpg -er raine
}

# encrypt ascii armored and pipe to stdout
# e.g. gpga < file.txt > file.txt.asc
gpga() {
  # requires "brew install gnupg"
  gpg -ear raine
}

# decrypt an image and pipe to Preview.app
gpgi() {
  # http://apple.stackexchange.com/questions/175977/preview-image-from-pipe/175981#175981
  # man open | grep -C 3 "\-f"
  gpg -o - "$@" | open -a Preview.app -f
}
