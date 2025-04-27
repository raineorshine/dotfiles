# .zhrc
# NOTE: This file should only contain commands that do not work in a bash environment. Prefer .bashrc.
# This is loaded whenever an interactive shell is opened.
# .bashrc and .zshrc can contain aliases, functions, and most anything except environment variables.

source ~/.bashrc

so() {
  source $dothome/.zshrc
}

# https://hub.github.com/
alias git=hub
alias brave="open -a Brave\ Browser"
alias chrome="open -a Google\ Chrome"
alias brew="arch -x86_64 brew"

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

# This file contains only zsh bindings. bash bindings are in .inputrc.
# Show all commands available in zsh for key binding: zle -al
# More info about key bindings: https://unix.stackexchange.com/questions/116562/key-bindings-table?rq=1

bindkey "\C-h" backward-char
# kills tab-completion!
# bindkey "\C-i" forward-char
bindkey "\C-b" backward-word
# ^? is backspace, but it does not work with the Control key for some reason
# bindkey "\C-^?" backward-kill-word
bindkey "\C-v" backward-kill-word
bindkey "\C-w" forward-word
bindkey "\C-f" kill-word
bindkey "\C-a" end-of-line

# Control + number does not work for some reason
bindkey "\C-h" beginning-of-line

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

# encrypt a file and save it as .asc (text) or .gpg (binary)
# requires "brew install gnupg"
gpge() {
if [ -z "$1" ]; then
    echo "Encrypt a file and save it as .asc (text) or .gpg (binary)"
    echo "\nUsage: gpge <filename>"
    echo "\nExamples:"
    echo "  gpge test.txt -> test.txt.asc"
    echo "  gpge test.jpg -> test.jpg.gpg"
    return 1
  fi

  local input_file="$1"
  local output_file
  local ext

  # Detect if file is a text file
  if file "$input_file" | grep -q 'text'; then
    gpg -ear raine --output "${input_file}.asc" "$input_file"
    echo "Encrypted: ${input_file}.asc"
  else
    gpg -er raine --output "${input_file}.gpg" "$input_file"
    echo "Encrypted: ${input_file}.gpg"
  fi
}

# decrypt a file and save it without the .asc or .gpg extension
gpgd() {
if [ -z "$1" ]; then
    echo "Decrypt a file and save it without the .asc or .gpg extension"
    echo "\nUsage: gpgd <filename>"
    echo "\nExamples:"
    echo "  gpgd test.txt.asc -> test.txt"
    echo "  gpgd test.jpg.gpg -> test.jpg"
    return 1
  fi

  local input_file="$1"
  local output_file
  local ext

  # Detect if file is a text file
  if file "$input_file" | grep -q 'text'; then
    output_file="${input_file%.asc}"
  else
    output_file="${input_file%.gpg}"
  fi

  gpg -d --output "$output_file" "$input_file"
  echo "Decrypted: $output_file"
}

# decrypt a file and preview with either less or Preview.app
gpgp() {
  local file="$1"
  if [[ "$file" == *.asc ]]; then
    gpg "$file" | less
  elif [[ "$file" == *.gpg ]]; then
    # http://apple.stackexchange.com/questions/175977/preview-image-from-pipe/175981#175981
    # man open | grep -C 3 "\-f"
    gpg -o - "$file" | open -a Preview.app -f
  else
    echo "Unsupported file type. Please provide a .asc or .gpg file."
    return 1
  fi
}

# encrypt ascii armored and pipe to stdout
# e.g. gpga < file.txt > file.txt.asc
gpga() {
  gpg -ear raine
}

# bun completions
[ -s "/Users/raine/.bun/_bun" ] && source "/Users/raine/.bun/_bun"

# completion
fpath+=~/.zcompletions
autoload -Uz compinit && compinit
