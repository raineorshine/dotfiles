#-------------------------#
# Aliases
#-------------------------#

alias ~="cs ~"
alias h="cs ~"
alias ..="cs .."
alias ...="cd ..;cs .."
alias ....="cd ..;cd ..;cs .."
alias .....="cd ..;cd ..;cd ..;cs .."
alias ls="ls -GF"
alias lsa="ls -AGF"
alias lsl="ls -AGFplh"
alias lst="ls -AGFplht"
alias c="pbcopy"
alias v="pbpaste"
alias pri="gpg -d ~/Google\ Drive/Finance/Accounts/private.json.asc | less"
alias so="source ~/.bashrc"
alias brave='open -a Brave\ Browser'
alias chrome='open -a Google\ Chrome'
alias flushdns='dscacheutil -flushcache;sudo killall -HUP mDNSResponder'
alias grep="grep --color=always"
alias tra="trash" # requires brew install trash
alias traa="trash ./*"
alias t="type"
alias backupsublime="~/Library/Application\ Support/Sublime\ Text\ 3/backup.sh"
alias backupatom="~/.atom/backup.sh"
alias b="pushd +1 >& /dev/null"
alias f="pushd -1 >& /dev/null && pushd +1 >& /dev/null"
alias m="mocha"
alias mb="mocha --bail"

# https://rtyley.github.io/bfg-repo-cleaner/
alias bfg="java -jar /usr/local/bin/bfg.jar"

# editing aliases
alias pro="subl ~/.bash_profile"

rc() {
  dotdiff
  subl ~/.bashrc
}

# icloud directory
ic() {
  pushd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Documents &> /dev/null
  ls
}

# project directory
p() {
  pushd ~/projects &> /dev/null
  ls
}

# Secure directory
s() {
  pushd ~/Documents/Secure &> /dev/null
}

md() {
  mkdir -p "$@"
  cd "$@"
}

cs() {
  cd "$@"
  ls
}

rl() {
  which "$@" | xargs readlink
}

# display [w]here a sym[l]inked executable is pointing
wl() {
  which "$@" | xargs ls -lG
}

# add, commit, and push ~/.bashrc to dotfiles repo
dotcommit() {
  dir=$(pwd)
  cd ~/projects/dotfiles

  so &&
  git add -A &&
  git commit -m "backup `date +%F-%T`"
  git push

  cd "$dir"
}

# diff the dotfiles repo
dotdiff() {
  dir=$(pwd)
  cd ~/projects/dotfiles

  git --no-pager diff --exit-code ||
  echo -e "\nRun 'dotcommit' to commit dotfile changes"

  cd "$dir"
}

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

# grep man page for a specific term
mang() {
  man "$1" | grep -n -C 2 "$2"
}

# echo the last command entered
prev() {
  history ${1:-2} | head -n 1 | sed 's/^ *[[:digit:]]* *//'
}

# Command-line usage: trim "abc   "
# Command-line usage: trim `echo "abc   "`
# Bash script usage:  $(trim "abc   ")
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

notify() {
  /usr/bin/osascript -e "display notification \"$*\" with title \"Notification\""
}

# empty the temp directory and cd there
temp() {
  rm -rf /tmp/temp ;
  mkdir /tmp/temp &&
  pushd /tmp/temp
}

# measure the running time of a command repeated n times
timen() {
  for i in $(seq 1 $1)
  do
    time $($2) &> /dev/null
  done
}

# create a blank package.json in the current folder if it does not exist
# https://gist.github.com/raineorshine/1c8288e915017004f1ebfd749b5cfe56
# raw url must be updated if modified
pkg() {
  copySource="$HOME/.blank-package.json"
  if [ ! -f ./package.json ]; then
    if [ ! -f $copySource ]; then
      echo "Copying"
      curl https://gist.githubusercontent.com/raineorshine/1c8288e915017004f1ebfd749b5cfe56/raw/4188a0601fb3accd1885636169bc9441b3bc10d0/new-package.json > $copySource
    fi
    cp $copySource ./package.json
    echo "package.json created"
  else
    echo "package.json already exists"
  fi
}

#-------------------------#
# gpg
#-------------------------#

alias gpg="gpg2 -o -"

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
alias pusht="git push && git push --tags"
alias pushh="git push && git push heroku master && heroku info -s | grep web_url | cut -d= -f2 | xargs -I{} curl {} -w '%{http_code}' -so /dev/null"
alias pushu="git push -u origin HEAD"
alias ff="git pull --ff-only"
alias gf="git fetch"

# commit
alias gm="git commit -m"
alias gre="git remote -v"

# merge
alias gmff="git merge --ff-only"
alias gmc="git merge --continue"
alias gma="git merge --abort"

# branch
alias gb="git branch -v"
alias gbre="git branch -vr"
alias gbra="git for-each-ref --color=always --sort=-committerdate refs/heads/ --format='  %(color:yellow)%(committerdate:short)%(color:reset) %(refname:short) %09 %(objectname:short) %(subject) %(color:blue)(%(authorname))%(color:reset)'"
alias gbr="gbra --count 20"
alias gbr10="gbra --count 10"
alias gbr20="gbra --count 20"
alias gbr30="gbra --count 20"
alias pwb="git rev-parse --abbrev-ref HEAD" # print working branch

# diff
alias gd="git diff"
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
alias gloo="git log --oneline"
alias glo="git log --oneline -10"
alias glo1="git log --oneline -1"
alias glo2="git log --oneline -2"
alias glo3="git log --oneline -3"
alias glo4="git log --oneline -4"
alias glo5="git log --oneline -5"
alias gl10="git log --oneline -10"
alias gl20="git log --oneline -20"
alias gl30="git log --oneline -30"
alias gl40="git log --oneline -40"
alias gl50="git log --oneline -50"
alias glf="git log -1 --pretty=fuller"

# rebase
alias gr="git rebase"
alias gro="git rebase --interactive head^^^^^^^^^^"
alias groo="git rebase --interactive head^^^^^^^^^^^^^^^^^^^^"
alias gri="git rebase --interactive"
alias gra="git rebase --abort"
alias grc="git rebase --continue"
alias grs="git rebase --skip"

# cherry-pick
alias gch="git cherry-pick"
alias gcha="git cherry-pick --abort"
alias gchc="git cherry-pick --continue"
alias gchs="git cherry-pick --skip"

# misc
alias ga="git add -A"
alias gbro="git browse"
alias gc="git checkout"
alias gh="git rev-parse --short HEAD | tr -d '\n'"
alias gi="git init && git add -A && git commit -m 'init'"
alias gres='git reset'
alias grh='git reset head^'
alias gs="git status"
alias gsp="git stash pop"
alias gspd="git stash show -p"
alias gsps="git stash show"
alias gst="git stash"
alias gt="git tag"
alias sub="git submodule init && git submodule update"

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
amend() {
  if [ $# -eq 0 ]
  then
    git commit --amend --no-edit
  else
    git commit --amend -m "$@"
  fi
}

# add all and amend with same message
aamend() {
  git add -A &&
  amend "$@"
}

# add and commit
gam() {
  git add -A &&
  git commit -m "$@"
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
  git push -u origin master
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

# delete branch from local and remote
gbd() {
  git branch -D "$@"
  git push origin --delete "$@"
}

#-------------------------#
# npm
#-------------------------#

alias ni="npm install"
alias nig="npm install -g"
alias nug="npm uninstall -g"
alias nu="npm update"
alias nv="npm view"
alias nis="npm install --save"
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
alias nw="npm run watch"
alias nb="npm run build"
alias l="npm run lint"
alias lint="npm run lint"
alias lf="npm run lintfix"

alias yi="yarn install"
alias ya="yarn add"
alias yr="yarn remove"
alias yl="yarn link"
alias yga="yarn global add"
alias ygr="yarn global remove"

# browse the home page of an npm module
nbro() {
  npm view "$@" homepage | xargs open
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
    echo "You must specify major|minor|patch"
    return 1
  else
    npm version "$@" &&
    git push &&
    git push --tags &&
    npm publish
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
    return 1
  else
    ffmpeg -i "$@" -r 25 -f gif - | gifsicle --optimize=3 --lossy=90 --scale 0.5 --colors=32 > "$@.gif"
  fi
}

#-------------------------#
# Miscellaneous
#-------------------------#

# added by travis gem
[ -f /Users/raine/.travis/travis.sh ] && source /Users/raine/.travis/travis.sh

alias node='env NODE_REPL_HISTORY_FILE=$HOME/.node_history node'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
