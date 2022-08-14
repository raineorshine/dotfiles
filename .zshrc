#-------------------------#
# Tips
#-------------------------#

# Reverse History Search: Ctrl + r
# Next: Ctrl + r
# Prev: Ctrl + s

# Suspend foreground process: Ctrl + Z
# Unsuspend: fg

# Exit code: $?

# Redirect stdout: 1>
# Redirect stderr: 2>

#-------------------------#
# CONSTANTS
#-------------------------#

# use echo -e to print colors
# e.g. echo -e "${RED}hello${NC}"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

dothome="$HOME/projects/dotfiles"

#-------------------------#
# UTIL
#-------------------------#

alias ~="cs ~"
alias ..="cs .."
alias ...="cd ..;cs .."
alias ....="cd ..;cd ..;cs .."
alias .....="cd ..;cd ..;cd ..;cs .."
alias b="pushd +1 >& /dev/null"
alias backupatom="~/.atom/backup.sh"
alias backupsublime="~/Library/Application\ Support/Sublime\ Text\ 3/backup.sh"
alias brave='open -a Brave\ Browser'
alias c="pbcopy"
alias chrome='open -a Google\ Chrome'
alias f="pushd -1 >& /dev/null && pushd +1 >& /dev/null"
alias fb="firebase"
alias fd="firebase deploy --only hosting"
alias fds="firebase hosting:channel:deploy staging"
alias flushdns='dscacheutil -flushcache;sudo killall -HUP mDNSResponder'
alias grep="grep --color=always"
alias h10="head -10"
alias h1="head -1"
alias h20="head -20"
alias h2="head -2"
alias h30="head -30"
alias h3="head -3"
alias h40="head -40"
alias h4="head -4"
alias h50="head -50"
alias h5="head -5"
alias h6="head -6"
alias h7="head -7"
alias h8="head -8"
alias h9="head -9"
alias h="cs ~"
alias less="less -R" # --raw-control-chars to parse color codes
alias lr="lessmd README.md"
alias ls="ls -GF"
alias lsa="ls -AGF"
alias lsl="ls -AGFplh"
alias lstc="ls -AGFplht --color=always"
alias lst="ls -AGFplht --color=always | grep -v .DS_Store | head -10"
alias lstt="ls -AGFplht"
alias lst10="ls -AGFplht --color=always | grep -v .DS_Store | head -10"
alias lst20="ls -AGFplht --color=always | grep -v .DS_Store | head -20"
alias lst30="ls -AGFplht --color=always | grep -v .DS_Store | head -30"
alias lst40="ls -AGFplht --color=always | grep -v .DS_Store | head -40"
alias lst50="ls -AGFplht --color=always | grep -v .DS_Store | head -50"
alias m="mocha"
alias mb="mocha --bail"
alias n="notify"
alias pro="subl $dothome/.zprofile"
alias rmrf="rm -rf"
alias so="source $dothome/.zshrc"
alias t="type -af"
alias tra="npx trash-cli"
alias traa="npx trash-cli ./*"
alias tw="npx tsc --watch"
alias v="pbpaste"

# alias mysqld="sudo mysqld_safe --skip-grant-tables --port=3306"

# https://rtyley.github.io/bfg-repo-cleaner/
alias bfg="java -jar /usr/local/bin/bfg.jar"

# prompt the user with a y/n question
confirm() {
  printf "$@"
  old_stty_cfg=$(stty -g)
  stty raw -echo
  answer=$( while ! head -c 1 ;do true ;done )
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y" ;then
    echo yes
    return 0
  else
    echo no
    return 1
  fi
}

# cd and ls
cs() {
  if [ $# -ne 0 ]
  then
    cd "$@"
  fi
  ls
}

# recursive copy, cd to the destinaation, and ls
cps() {
  cp -r "$1" "$2"
  cs "$2"
}

# icloud directory
ic() {
  pushd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Documents &> /dev/null
  ls
}

# read markdown file with marked-terminal-cli and pass to less
lessmd() {
  FORCE_COLOR=1 marked-terminal-cli "$@" | less -r
}

# repeat a command n times
loop() {
  n=$1
  shift
  for i in $(seq 1 $n)
  do
    "$@"
  done
}

# grep man page for a specific term
mang() {
  man "$1" | grep -n -C 2 "$2"
}

# make a directory and cd to it
md() {
  mkdir -p "$@"
  cd "$@"
}

notify() {
  /usr/bin/osascript -e "display notification \"$*\" with title \"Notification\""
}

# project directory
p() {
  pushd ~/projects &> /dev/null
  ls -AGFplht --color=always | grep -v .DS_Store | tail +2 | head -10
  echo ...
}

# create a blank package.json in the current folder if it does not exist
# https://gist.github.com/raineorshine/1c8288e915017004f1ebfd749b5cfe56
# raw url must be updated if modified
pkg() {
  cachedPkg="$HOME/package.new.json"
  src="https://gist.githubusercontent.com/raineorshine/1c8288e915017004f1ebfd749b5cfe56/raw/4e8798fb8240b9cdc6f037f8e9859ca66546fecb/new-package.json"
  if [ ! -f ./package.json ]; then
    if [ ! -f $cachedPkg ]; then
      echo "Copying"
      curl $src > $cachedPkg
    fi
    cp $cachedPkg ./package.json
    echo "package.json created"
  else
    echo "package.json already exists"
  fi
}

# get the process using a port
port() {
  lsof -i ":$@"
}

# echo the last command(s) entered
prev() {
  if [ $# -eq 0 ]
  then
    n=1
  else
    n="$@"
  fi
  history "-$n" | head -1 | sed 's/^ *[[:digit:]]* *//'
}

# edit .zhrc file
rc() {
  dd
  subl "$dothome/.zshrc"
}

rl() {
  which "$@" | xargs readlink
}

# Secure directory
s() {
  pushd ~/Documents/Secure &> /dev/null
}

# empty the temp directory and cd there
temp() {
  rm -rf /tmp/temp ;
  mkdir /tmp/temp &&
  pushd /tmp/temp
}

# measure the running time of a command repeated n times
timen() {
  n=$1
  shift
  for i in $(seq 1 $n)
  do
    time "$@" &> /dev/null
  done
}

# Command-line usage: trim "abc   "
# Command-line usage: trim `echo "abc   "`
# Script usage:  $(trim "abc   ")
trim() {
    # Determine if 'extglob' is currently on.
    local extglobWasOff=1
    shopt extglob >/dev/null && extglobWasOff=0
    (( extglobWasOff )) && shopt -s extglob # Turn 'extglob' on, if currently turned off.
    # Trim leading and trailing whitespace
    local var=$1
    var=${var##+([[:space:]])}
    var=${var%%+([[:space:]])}
    (( extglobWasOff )) && shopt -u extglob # If 'extglob' was off before, turn it back off.
    echo -n "$var"  # Output trimmed string.
}

# display [w]here a sym[l]inked executable is pointing
wl() {
  which "$@" | xargs ls -lG
}

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
daf() {
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

#-------------------------#
# git
#-------------------------#

alias git=hub

# push/pull/fetch
alias push="git push origin HEAD"
alias pusht="git push && git push --no-verify --tags"
alias pushh="git push && git push --no-verify heroku master && heroku info -s | grep web_url | cut -d= -f2 | xargs -I{} curl {} -w '%{http_code}' -so /dev/null"
alias pushu="git push -u origin HEAD"
alias ff="git pull --ff-only"
alias ffd="git pull --ff-only origin dev"
alias gf="git fetch"

# merge
alias gme="git merge"
alias gmff="git merge --ff-only"
alias gmc="git merge --continue"
alias gma="git merge --abort"

# branch
alias gb10="gbra --count 10"
alias gb20="gbra --count 20"
alias gb30="gbra --count 30"
alias gbm="git branch --merged"
# verbose + remote
alias gbr="git branch -vr"
# verbose + date + committer
# used by gb as default
alias gbra="git for-each-ref --color=always --sort=-committerdate refs/heads/ --format='%(color:yellow)%(committerdate:short)%(color:reset) %(align:width=18)%(refname:short)%(end) %(objectname:short) %(subject) %(color:blue)(%(authorname))%(color:reset)'"
alias pwb="git rev-parse --abbrev-ref HEAD" # print working branch

# diff
alias gd="git diff"
alias gdn="git diff --name-only"
alias gdn1="git diff --name-only head^ head"
alias gds="git diff --staged"
alias gd1="git diff head^ head"
alias gd2="git diff head^^ head"
alias gd3="git diff head^^^ head"
alias gdp="git diff package.json"
alias fix="git diff --name-only | uniq | xargs subl -n"

# log
alias gl="git log"
alias gl1="git log -1"
alias gl2="git log -2"
alias gl3="git log -3"
alias gl4="git log -4"
alias gl5="git log -5"
alias gl5="git log -5"
alias gl6="git log -5"
alias gl7="git log -5"
alias gl8="git log -5"
alias gl9="git log -5"
alias glo="git log --oneline -10"
alias gloo="git log --oneline"
alias gl10="git log --oneline -10"
alias gl20="git log --oneline -20"
alias gl30="git log --oneline -30"
alias gl40="git log --oneline -40"
alias gl50="git log --oneline -50"
alias glo1="git log --oneline -1"
alias glo2="git log --oneline -2"
alias glo3="git log --oneline -3"
alias glo4="git log --oneline -4"
alias glo5="git log --oneline -5"
alias glf="git log -1 --pretty=fuller"

# rebase
alias gr="git rebase"
alias gro="git rebase --interactive head^^^^^^^^^^"
alias groo="git rebase --interactive head^^^^^^^^^^^^^^^^^^^^"
alias gri="git rebase --interactive"
alias gri2="git rebase --interactive head^^"
alias gri3="git rebase --interactive head^^^"
alias gri4="git rebase --interactive head^^^^"
alias gri5="git rebase --interactive head^^^^^"
alias grii="git rebase --interactive head^^"
alias griii="git rebase --interactive head^^^"
alias griiii="git rebase --interactive head^^^^"
alias griiiii="git rebase --interactive head^^^^^"
alias grid="git rebase --interactive origin/dev"
alias gra="git rebase --abort"
alias grc="git rebase --continue"
alias grk="git rebase --skip"

# cherry-pick
alias gch="git cherry-pick"
alias gcha="git cherry-pick --abort"
alias gchc="git cherry-pick --continue"
alias gchs="git cherry-pick --skip"

# misc
alias a="amend"
alias aa="aamend"
alias ga="git add -A"
alias gaat="ga && gat"
alias gbro="git browse"
alias gc="git checkout"
alias gh="git rev-parse --short HEAD | tr -d '\n'"
alias gi="git init && git add -A && git commit -m 'init'"
alias grs='git reset'
alias grh='git reset head^'
alias grha='git reset --hard'
alias grhh='git reset --hard head^'
alias grhhh='git reset --hard head^^'
alias grhhhh='git reset --hard head^^^'
alias grhhhhh='git reset --hard head^^^^'
alias grhhhhhh='git reset --hard head^^^^^'
alias grm="git remote -v"
alias gs="git status"
alias gsc="gc stash@{0}"
alias gsl="git stash list | head -10"
alias gsll="git stash list"
alias gsn="git stash show --name-only"
alias gsp="git stash pop"
alias gsd="git stash show -p"
alias gsps="git stash show"
alias gst="git stash"
alias gt="git tag"
alias sub="git submodule init && git submodule update"

# git tab completion
autoload -Uz compinit && compinit

# pull all submodules
pull() {
  git pull "$@" && git submodule update --init --recursive
}

spull() {
  git stash
  pull
  git stash pop
}

# git stash list
gstls() {
  if [ $# -eq 0 ]
  then
    git stash list | head -10
  else
    git stash list | head "-$@"
  fi
}

# amend with optional new message
# if no message is provided and there are staged changes, amend the commit with the changes
# otherwise, if no message is provided and there are no staged changes, prompt for a new commit message (and ignore unstaged changes)
amend() {
  if [ $# -ne 0 ]
  then
    git commit --amend -m "$@"
  elif [ -z "$(git diff --cached --exit-code)" ]
  then
    GIT_EDITOR=vim git commit --amend
  else
    git commit --amend --no-edit
  fi
}

# add all and amend with same message
aamend() {
  git add -A &&
  amend "$@"
}

# amend at a specific commit
gat() {
  # see ~/.gitconfig for amend-to definition
  git amend-to "$@"
}

# add all and commit
# When no arguments are provided, opens $EDITOR to write the commit message
# Usage:
#   gam
#   gam [shortmessage]
#   gam [shortmessage] -m [longmessage]
gam() {
  git add -A
  if [ $# -ne 0 ]
  then
    git commit -m "$@"
  else
    git commit
  fi
}

# git commit
# When no arguments are provided, opens $EDITOR to write the commit message
# Usage:
#   gm
#   gm [shortmessage]
#   gm [shortmessage] -m [longmessage]
gm() {
  if [ $# -ne 0 ]
  then
    git commit -m "$@"
  else
    git commit
  fi
}

# checkout prev (older) commit
gp() {
  git checkout HEAD~
}

# checkout next (newer) commit
gn() {
  branch=`git show-ref | grep $(git show-ref -s -- HEAD) | sed 's|.*/\(.*\)|\1|' | grep -v HEAD | sort | uniq`
  hash=`git rev-parse $branch`
  prev=`git rev-list --topo-order HEAD..$hash | tail -1`
  git checkout $prev
}

# git commit and tag
gcat() {
  printf -v v "v%s" $(cat package.json | jsonpath version)
  git commit -m "$v"
  git tag "$v"
}

# git clone and cd
gcl() {
  if [ $# -eq 2 ]
  then
    git clone "$1" "$2" &&
    cs "$2"
  else
    git clone $1 &&
    cs $(basename $1)
  fi
}

# git create with the description set from your package.json
# requires jq be installed
gcreate() {
  desc=`cat package.json | jq -r .description` &&
  git create -d "$desc" &&
  git push -u origin HEAD
}

# git create, bump to first major version, and publish to npm
createandpub() {
  gcreate &&
  npub major
}

# git create, bump to first major version, publish to npm, and trigger travis build
createandpubt() {
  gcreate &&
  pushu &&
  npub major &&
  yes | travis enable &&
  git commit --amend --no-edit && git push -f # trigger travis build
}

# force push
force() {
  push --force
}

# add, amend, and force push
aforce() {
  git add -A &&
  amend &&
  push --force
}

# log commits since origin/dev (inclusive)
gld() {
  git log origin/dev^..HEAD --oneline
}

# log commits since last tag (inclusive)
glt() {
  git log $(git describe --tags --abbrev=0)^..HEAD --oneline
}

# list branches in reverse chronological order (using for-each-ref)
# if arguments are passed, use git branch
gb() {
  if [ $# -eq 0 ]
  then
    gbra --count 10
  else
    git branch "$@"
  fi
}

# delete branch from local and remote
gbd() {
  git branch -D "$@"
  git push origin --delete "$@"
}

# delete all remote branches that are not in the local repo
gbda() {
  git fetch --prune
  for branch in $(git for-each-ref --format='%(refname:lstrip=3)' refs/remotes/origin); do
    if ! git show-ref --quiet refs/heads/${branch}; then
      echo "Delete remote branch '${branch}'"
      git push origin --delete ${branch}
    fi
  done
}

# stash console.logs
rmc() {
  # stage current changes
  git add -A &&

  # remove console.logs
  rm-diff-consoles &&

  # store the diff
  reverseDiff=$(git diff -R) &&
  reverseDiffColor=$(git diff -R --color=always) &&
  echo -e $reverseDiffColor &&

  # stage the removed console.logs
  git add -A &&

  # make a temporary commit
  # the commit message will show up in the stash
  git commit --quiet -m "console.logs" &&

  # restore the console.logs by applying the reverse patch
  echo $reverseDiff | git apply &&

  # stash the console.logs in case we changed our mind
  git stash --quiet &&
  echo "${GREEN}✓${NC} console.logs stashed" &&

  # reset the TEMP commit so the original changes minus console.logs are restored
  git reset --quiet head^
}

#-------------------------#
# npm
#-------------------------#

alias ni="npm install"
alias nig="npm install --location=global"
alias nug="npm uninstall -g"
alias nu="npm update"
alias nv="npm view"
alias nisd="npm install --save-dev"
alias nun="npm uninstall"
alias nus="npm uninstall --save"
alias nusd="npm uninstall --save-dev"
alias nls="npm ls --depth=0"
alias npmo="npm outdated --depth=0"
alias nr="npm run"
alias ns="npm start"
alias nt="npm test"
alias ntw="npm test -- --watch"
alias nre="npm repo"
alias nw="npm run watch || npx tsc --watch"
alias nb="npm run build"
alias nbw="npm run build -- --watch"
alias l="npm run lint"
alias lint="npm run lint"
alias ll="npm run lint:src"
alias lf="npm run lint -- --fix"
alias lnt="npm run lint && npm run test"
alias nrd="npm run deploy && pusht"

alias y="yarn"
alias ya="yarn add"
alias yad="yarn add --dev"
alias yr="yarn remove"
alias yl="yarn link"
alias yga="yarn global add"
alias ygr="yarn global remove"

# show a package's tags
dt() {
  npm view "$@" dist-tags
}

# browse the home page of an npm module
nbro() {
  npm view "$@" homepage | xargs open
}

# npm view short
nvs() {
  underline=`tput smul`
  yellow=`tput setaf 3`
  cyan=`tput setaf 6`
  reset=`tput sgr0`
  pkg=$(npm view --json "$@" name description homepage version)
  name=$(echo "$pkg" | jq -r ".name")
  description=$(echo "$pkg" | jq -r ".description")
  homepage=$(echo "$pkg" | jq -r ".homepage")
  version=$(echo "$pkg" | jq -r ".version")
  echo
  echo "$yellow$underline$name@$version$reset"
  if [ $description != "null" ]
  then
    echo $description
  fi
  if [ $homepage != "null" ]
  then
    echo "$cyan$homepage$reset"
  fi
  echo
}

# npm versions
nvv() {
  npm view "$@" versions
}

# npm time
nvt() {
  npm view "$@" time
}

# bump the version, push, and publish
npub() {

  if [ $# -eq 0 ]
  then
    echo "You must specify major|minor|patch" >&2
    return 1
  else
    npm version "$@" &&
    git push &&
    git push --no-verify --tags &&
    npm publish
  fi

}

# show files that will be published to npm
nf() {
  name=$(jq -r .name < package.json)
  version=$(jq -r .version < package.json)
  tarfile="$name-$version.tgz"
  npm pack
  tar -tzf $tarfile
  rm -rf $tarfile
}

#-------------------------#
# Karabiner
#-------------------------#

# edit karabiner.json
kar() {
  kardiff
  subl ~/.config/karabiner/karabiner.json
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
# JSON
#-------------------------#

# parse a json file and output to less with syntax highlighting
# select a specific property by passing a jq selector as a second argument (outputs without less)
lo() {
  if [ $# -eq 0 ]
  then
    echo "Please specify a json or markdown file"
    return 1
  fi

  EXT=$(echo $1 | sed 's/^.*\.//')

  case $EXT in

    # json
    json)
      if [ $# -eq 1 ]
      then
        jq $2 < $1 -C | less -R
      else
        jq $2 < $1 -C
      fi
      ;;

    # markdown
    md)
      # check that marked-terminal is installed
      # npx marked-terminal-cli is too slow, so install the global
      MARKED_TERMINAL_TYPE=$(type -af marked-terminal-cli)
      if [ "$MARKED_TERMINAL_TYPE" = "marked-terminal-cli not found" ]
      then
        # printf 'Install marked-terminal-cli (y/n)? '
        # read -n 1 -p "Is this a good question (y/n)? " answer
        confirm "Install marked-terminal-cli (y/n)? "
        if [ "$?" -eq 1 ]
        then
          return 1
        fi
        npm install -g marked-terminal-cli
      fi
      FORCE_COLOR=1 marked-terminal-cli "$1" | less -r
      ;;

    # other
    *)
      less $1
  esac
}

# parse the package.json file and output to less with syntax highlighting
# select a specific property by passing a jq selector as an argument (outputs without less)
lp() {
  if [ $# -eq 0 ]
  then
    jq < package.json -C | less -R
  else
    jq $@ < package.json
  fi
}

#-------------------------#
# Video Processing
#-------------------------#

# convert a video to an animated gif
togif() {
  if [ $# -lt 1 ]
  then
    echo "Converts a video to a compressed, animated gif. Outputs to INPUT.MOV.gif"
    echo ""
    echo "Usage:"
    echo "togif input.mov"
  else
    ffmpeg -i "$@" -r 25 -f gif - | gifsicle --optimize=3 --lossy=90 --scale 0.5 --colors=32 > "$@.gif"
  fi
}

#-------------------------#
# Key Bindings
#-------------------------#

set show-all-if-ambiguous on
set completion-ignore-case on
set editing-mode vi

# http://stackoverflow.com/questions/23349325/inputrc-override-controlw
set bind-tty-special-chars Off

bindkey "\C-h" backward-char
# kills tab-completion!
# bindkey "\C-i" forward-char
bindkey "\C-b" backward-word
bindkey "\C-a" end-of-line

# doesn't work?
bindkey "\C-0" beginning-of-line
bindkey "\C-p" beginning-of-line

#-------------------------#
# Miscellaneous
#-------------------------#

PROMPT="%F{yellow}%n%f%F{cyan}[%1~]%# %f"

# display "✓" on right side if error code 0, otherwise display "✗"
RPROMPT="%(?.%F{green}✓%f.%F{red}✗%f)"

# strip rprompt checkmark
# useful for copying the shell output to a github issue
alias stripr=sed 's/\w*✓//'

# timestamp
# RPROMPT="%*"

# set window title to current working directory after returning from a command
precmd() { echo -ne "\e]1;${PWD##*/}\a" }

# added by travis gem
[ -f /Users/raine/.travis/travis.sh ] && source /Users/raine/.travis/travis.sh

alias node='env NODE_REPL_HISTORY_FILE=$HOME/.node_history node'
