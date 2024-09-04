# .bashrc
# This is loaded whenever a login shell is opened. It can safely be loaded in ssh environments.
# .bashrc and .zshrc can contain aliases, functions, and most anything except environment variables.

#-------------------------#
# Tips
#-------------------------#

# Reverse History Search:       Ctrl + r
#   Next:                       Ctrl + r
#   Prev:                       Ctrl + s
# Suspend foreground process:   Ctrl + Z
#   Unsuspend:                  fg
# Exit code:                    $?
# Redirect stdout:              1>
# Redirect stderr:              2>
# Symlink:                      ln -s source name
# Shell parameter expansion     a=${VAR:-20}
#   https://stackoverflow.com/a/12691027/480608
# If statement tests:           man test
#   ( expression )              true
#   ! expression                false
#   exp1 -a exp2                and
#   exp1 -o exp2                or
#   str1 = str2                 string equal
#   str1 != str2                string not equal
#   -n                          non-zero-length string
#   -z                          zero-length string
#   -d                          directory exists
#   -f                          file exists
#   -s                          file is not empty
#   -x                          executable exists
#   -eq                         integer equal
#   -ne                         integer not equal
#   -gt                         integer greater than
#   -ge                         integer greater than or equal
#   -lt                         integer less than
#   -le                         integer less than or equal

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
alias backupsublime="~/Library/Application\ Support/Sublime\ Text/backup.sh"
alias c="pbcopy"
alias cdot="cd $dothome && git status"
alias f="pushd -1 >& /dev/null && pushd +1 >& /dev/null"
alias fb="firebase"
alias fd="firebase deploy --only hosting"
alias fds="firebase hosting:channel:deploy staging"
alias fnu="fnm use"
alias flushdns='dscacheutil -flushcache;sudo killall -HUP mDNSResponder'
alias grep="grep --color=always"
alias grepi="grep -i"
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
alias less="less -R" # --raw-control-chars to parse color codes
alias lr="lessmd README.md"
# basic ls with colorized output (-G) and file type suffixes (-F)
alias ls="ls -GF"
# all files (-A), including hidden dot files
alias lsa="ls -AGF"
# long format (-l) with human readable sizes (-h)
alias lsl="ls -AGFplh"
# long format (-l) with exact byte sizes
alias lsll="ls -AGFpl"
# sort by most recent with forced color
alias lstc="ls -AGFplht --color=always"
# sort by most recent with forced color, exclude .DS_Store, and limit to 10
alias lst="ls -AGFplht --color=always | grep -v .DS_Store | head -10"
# sort by most recent
alias lstt="ls -AGFplht"
alias lst10="ls -AGFplht --color=always | grep -v .DS_Store | head -10"
alias lst20="ls -AGFplht --color=always | grep -v .DS_Store | head -20"
alias lst30="ls -AGFplht --color=always | grep -v .DS_Store | head -30"
alias lst40="ls -AGFplht --color=always | grep -v .DS_Store | head -40"
alias lst50="ls -AGFplht --color=always | grep -v .DS_Store | head -50"
alias m="mocha"
alias mb="mocha --bail"
alias n="notify"
alias nov="node -v"
alias pro="$EDITOR $dothome/.bash_profile"
alias zpro="$EDITOR $dothome/.zprofile"
alias rmrf="rm -rf"
# strip colors
alias strip='sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g"'
alias t="type -af"
alias tra="npx trash-cli"
alias traa="npx trash-cli ./*"
alias tw="npx tsc --watch"
alias v="pbpaste"
alias va="v > /tmp/a"
alias vb="v > /tmp/b"
alias vc="v > /tmp/c"
alias dab="git diff /tmp/a /tmp/b"
alias dac="git diff /tmp/a /tmp/c"
alias dba="git diff /tmp/b /tmp/a"
alias dbc="git diff /tmp/b /tmp/c"
alias dca="git diff /tmp/c /tmp/a"
alias dcb="git diff /tmp/c /tmp/b"
# xargs using placeholder %
# increase replstr size (-I)
alias xa="xargs --verbose -S 100000 -I%"
# interactive prompts for y/n
alias xap="xargs --verbose --interactive -S 100000 -I%"

# alias mysqld="sudo mysqld_safe --skip-grant-tables --port=3306"

# https://rtyley.github.io/bfg-repo-cleaner/
alias bfg="java -jar /usr/local/bin/bfg.jar"

so() {
  source $dothome/.bashrc
}

# prompt the user with a y/n question
confirm() {
  printf "$@"
  old_stty_cfg=$(stty -g)
  stty raw -echo
  answer=$(while ! head -c 1; do true; done)
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y"; then
    echo yes
    return 0
  else
    echo no
    return 1
  fi
}

# cd and ls
cs() {
  # Stay in the same directory if no arg is provided.
  # Otherwise it will go to the user's home directory.
  if [ $# -ne 0 ]; then
    cd "$@"
  fi
  ls
}

# recursive copy, cd to the destinaation, and ls
cps() {
  cp -r "$1" "$2"
  cs "$2"
}

# read markdown file with marked-terminal-cli and pass to less
lessmd() {
  FORCE_COLOR=1 marked-terminal-cli "$@" | less -r
}

# repeat a command n times
loop() {
  n=$1
  shift
  for i in $(seq 1 $n); do
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

# create a blank package.json in the current folder if it does not exist
# https://gist.github.com/raineorshine/1c8288e915017004f1ebfd749b5cfe56
# raw url must be updated if modified
pkg() {
  src="https://gist.githubusercontent.com/raineorshine/1c8288e915017004f1ebfd749b5cfe56/raw/c458511c390368e8dba14ac41f943b61bbe84820/package.json"
  dest="$HOME/package.new.json"

  if [ ! -f ./package.json ]; then
    if [ ! -f $dest ]; then
      echo "Copying"
      curl $src >$dest
    fi
    cp $dest ./package.json
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
  n=${@:-1}
  history "-$n" | head -1 | sed 's/^ *[[:digit:]]* *//'
}

# edit .bashrc file
rc() {
  dd
  $EDITOR "$dothome/.bashrc"
}

# edit .zhrc file
zrc() {
  dd
  $EDITOR "$dothome/.zshrc"
}

# edit .npmrc file
nrc() {
  $EDITOR ~/.npmrc
}

rl() {
  which "$@" | xargs readlink
}

# empty the temp directory and cd there
temp() {
  rm -rf /tmp/temp
  mkdir /tmp/temp &&
    pushd /tmp/temp
}

# measure the running time of a command repeated n times
# e.g. timen 3 sleep 1
timen() {
  n=$1
  command=$2
  args="${@:3}"
  for i in $(seq 1 $n); do
    time "$command" "$args" &>/dev/null
  done
}

# Command-line usage: trim "abc   "
# Command-line usage: trim `echo "abc   "`
# Script usage:  $(trim "abc   ")
trim() {
  # Determine if 'extglob' is currently on.
  local extglobWasOff=1
  shopt extglob >/dev/null && extglobWasOff=0
  ((extglobWasOff)) && shopt -s extglob # Turn 'extglob' on, if currently turned off.
  # Trim leading and trailing whitespace
  local var=$1
  var=${var##+([[:space:]])}
  var=${var%%+([[:space:]])}
  ((extglobWasOff)) && shopt -u extglob # If 'extglob' was off before, turn it back off.
  echo -n "$var"                        # Output trimmed string.
}

# display [w]here a sym[l]inked executable is pointing
wl() {
  which "$@" | xargs ls -lG
}

# man with support for builtins
h() {
  case $(type $1) in
  *"shell builtin"*)
    if [[ -n $ZSH_VERSION ]]; then
      man zshbuiltins | less -p "^       $1 "
    else
      man bash | less -p "^       $1 "
    fi
    ;;
  *) man "$1" ;;
  esac
}

#-------------------------#
# git
#-------------------------#

# push/pull/fetch
alias push="git push origin HEAD"
# push and skip pre-push hooks
alias pushn="HUSKY_SKIP_HOOKS=1 git push origin HEAD --no-verify"
# push and push tags
alias pusht="git push && git push --no-verify --tags"
# push and push tags to heroku
alias pushh="git push && git push --no-verify heroku master && heroku info -s | grep web_url | cut -d= -f2 | xargs -I{} curl {} -w '%{http_code}' -so /dev/null"
# push and set upstream to origin branch of the same name
alias pushu="git push --set-upstream origin HEAD"
# force push to origin
alias force="git push origin HEAD --force"
# force push and set upstream to origin branch of the same name
alias forceu="git push --set-upstream origin HEAD --force"
# force push and skip pre-push hooks
alias forcen="HUSKY_SKIP_HOOKS=1 git push origin HEAD --no-verify --force"
# force push to the current branch's upstream
alias forcepr="pushpr --force"
# fetch current branch from origin
alias ff='git pull --ff-only origin $(git_local_branch)'
# fetches all remote branches
alias ffa="git pull --ff-only"
# fetch current branch from upstream
alias ffu='git pull --ff-only upstream $(git_local_branch)'
alias gf="git fetch"
alias gfd="git fetch --deepen"
alias gfu="git fetch --unshallow"
# pull upstream into current branch
alias up='git pull upstream $(git_local_branch)'

# bisect
alias gbi="git bisect"
alias bil="git bisect log"
alias bir="git bisect reset"

# merge
alias gme="git merge"
alias gmff="git merge --ff-only"

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
alias pwb="git_local_branch" # print working branch

# diff
alias gd="git diff"
alias gdn="git diff --name-only"
alias gddn="git diff --name-only head^ head"
alias gds="git diff --staged"
alias gdsn="git diff --staged --name-only"
alias gdp="git diff package.json"
alias gdsp="git diff --staged package.json"
# show the changes of the last two commits
alias gd2="git diff head^^ head"
# show the changes of the last three commits
alias gd3="git diff head^^^ head"
# show the changes of the penultimate commit
alias gdd2="git diff head^^ head^"
# show the changes of the antepenultimate commit
alias gdd3="git diff head^^^ head^^"
alias fix="git diff --name-only | uniq | xargs $EDITOR -n"

# log
alias gl="git log"
alias gloo="git log --oneline"
alias gll="git log -1"
alias gl1="git log -1"
alias gl2="git log -2"
alias gl3="git log -3"
alias gl4="git log -4"
alias gl5="git log -5"
alias gl5="git log -5"
alias gl6="git log -6"
alias gl7="git log -7"
alias gl8="git log -8"
alias gl9="git log -9"
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
alias gl100="git log --oneline -100"
alias glf="git log -1 --pretty=fuller"
# log message only
alias glm="git log -1 --pretty=format:%s"

# rebase
alias gr="git rebase"
alias gri="git rebase --interactive"
alias gri2="git rebase --interactive head^^"
alias gri3="git rebase --interactive head^^^"
alias gri4="git rebase --interactive head^^^^"
alias gri5="git rebase --interactive head^^^^^"
alias gri10="git rebase --interactive head^^^^^^^^^^"
alias gri20="git rebase --interactive head^^^^^^^^^^^^^^^^^^^^"
alias grii="git rebase --interactive head^^"
alias griii="git rebase --interactive head^^^"
alias griiii="git rebase --interactive head^^^^"
alias griiiii="git rebase --interactive head^^^^^"
alias griiiiii="git rebase --interactive head^^^^^^"
alias griiiiiii="git rebase --interactive head^^^^^^^"
alias griiiiiiii="git rebase --interactive head^^^^^^^^"
alias griiiiiiiii="git rebase --interactive head^^^^^^^^^"
alias griiiiiiiiii="git rebase --interactive head^^^^^^^^^^"
alias gro="git rebase origin"

# cherry-pick
alias gch="git cherry-pick"

# revert
alias gv="git revert"
# only stage the revert, don't commit it
# useful for reverting multiple commits with COMMIT_START..COMMIT_END
alias gvn="git revert --no-commit"

# misc
alias a="amend"
alias aa="aamend"
alias ga="git add -A"
# amend-to a given commit or :/search pattern
alias gaat="ga && gat"
# amend-to second-to-last commit
alias gaatt="ga && gat head^"
# amend-to third-to-last commit
alias gaattt="ga && gat head^^"
alias gbro="git browse"
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
alias gs="git status"
alias gso="git status && git log --oneline -10"
# git stash list 10
alias gsl="git stash list | head -10"
# git stash list all
alias gsll="git stash list"
# git stash pop
alias gsp="git stash pop"
# git stash
alias gst="git stash"
# git stash show
alias gss="git stash show"
# git stash name only
alias gsn="git stash show --name-only"
# git stash show diff
alias gsd="git stash show -p"
# git stash checkout without popping
alias gsc="gc stash@{0}"
# exit detached HEAD state
alias gsw="git switch -"
alias gt="git tag"
alias sub="git submodule init && git submodule update"
# local branch name
alias git_local_branch="git rev-parse --abbrev-ref HEAD"

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
  n=${@:--10}
  git stash list | head $n
}

# amend with optional new message
# if no message is provided and there are staged changes, amend the commit with the changes
# otherwise, if no message is provided and there are no staged changes, prompt for a new commit message (and ignore unstaged changes)
amend() {
  if [ $# -ne 0 ]; then
    git commit --amend -m "$@"
  elif [ -z "$(git diff --cached --exit-code)" ]; then
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
  if [ $# -ne 0 ]; then
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
  if [ $# -ne 0 ]; then
    git commit -m "$@"
  else
    git commit
  fi
}

# save branch name (if not detached)
# this allows gcr to exit detached HEAD state and gn to better determine the next commit
git_save_branch() {
  branch=$(git_local_branch)
  if [ "$branch" != "HEAD" ]; then
    echo "$branch" >.git/_PREV_BRANCH
  fi
}

# loads the previously saved branch name, or guesses what branch we are in if detached
git_load_branch() {
  if [ -f .git/_PREV_BRANCH ]; then
    cat .git/_PREV_BRANCH
  else
    git branch --contains HEAD | grep -v HEAD | tail -1 | sed 's/^[ *]*//g'
  fi
}

# Use an alias to get git autocompletions for gc.
# Unable to find a way to get git autocompletions for a function.
# Ideally would call fnm use 2>/dev/null after checkout, but this is not possible with an alias.
alias gc="git_save_branch ; git checkout"
alias gcm="git_save_branch ; git checkout main"

# reset to last saved branch
gcr() {
  branch=$(git_load_branch)
  if [ -n "$branch" ]; then
    git checkout "$branch"
  else
    echo "No saved branch to reset to"
    return 1
  fi
}

# checkout prev (older) commit
gp() {
  git_save_branch
  git checkout HEAD~
}

# checkout next (newer) commit
gn() {
  branch=$(git_load_branch)
  hash=$(git rev-parse $branch)

  # stop if we are already on the branch, i.e. there are no newer commits
  head_hash=$(git rev-parse HEAD)
  if [ $hash = $head_hash ]; then
    echo "On branch $branch"
    return 0
  fi

  next=$(git rev-list --topo-order HEAD..$hash | tail -1)

  # if the next commit is the branch commit, checkout the branch to exit detached HEAD state
  if [ $next = $hash ]; then
    git checkout $branch
  # otherwise, checkout the next commit
  else
    git checkout $next
  fi
}

# git commit and tag
gcat() {
  printf -v v "v%s" $(cat package.json | jsonpath version)
  git commit -m "$v"
  git tag "$v"
}

# git clone (shallow)
gcl() {
  if [ $# -eq 2 ]; then
    git clone --depth=1 "$1" "$2" &&
      cs "$2"
  else
    git clone --depth=1 $1 &&
      cs $(basename $1)
  fi
}

# git clone (unshallow)
gclu() {
  if [ $# -eq 2 ]; then
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
  desc=$(cat package.json | jq -r .description) &&
    hub create -d "$desc" &&
    git push --set-upstream origin HEAD
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

# add, amend, and force push
aforce() {
  git add -A &&
    amend &&
    push --force
}

# log commits since origin/{branch} (inclusive)
glor() {
  git log origin/$(git_local_branch)^..HEAD --oneline
}

# log commits since last tag (inclusive)
glt() {
  git log $(git describe --tags --abbrev=0)^..HEAD --oneline
}

# diff since last tag (inclusive)
gdt() {
  git diff $(git describe --tags --abbrev=0)^..HEAD --oneline
}

# hard reset to origin
grhao() {
  git reset --hard origin/$(git_local_branch)
}

# hard reset to last tag
grhat() {
  git reset --hard $(git describe --tags --abbrev=0)
}

# git checkout last tag
gcit() {
  git_save_branch
  git checkout $(git describe --tags --abbrev=0)^
}

# rebase to last tag (inclusive)
grit() {
  git rebase --interactive $(git describe --tags --abbrev=0)^
}

# interactive rebase to origin/CURRENT_BRANCH (exclusive)
grio() {
  git rebase --interactive origin/$(git_local_branch)
}

# list branches in reverse chronological order (using for-each-ref)
# if arguments are passed, use git branch
gb() {
  if [ $# -eq 0 ]; then
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

# git remote - verbose if no args
grm() {
  args=${@:--v}
  git remote $args
}

# git remote add
grma() {
  git remote add "$@" &&
    git remote -v
}

# git remote remove
grmr() {
  git remote remove "$@" &&
    git remote -v
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

# start bisecting if we are not already, and then call git bisect [value]
bisect() {
  LOG=$(git bisect log &>/dev/null)
  if [ "$?" -eq 1 ]; then
    echo "starting bisect"
    git bisect start &>/dev/null
  fi

  git bisect $1
}

# start bisecting if we are not already, and then call git bisect bad
gig() {
  bisect good
}

# start bisecting if we are not already, and then call git bisect good
bib() {
  bisect bad
}

# git tag delete on local and remote
# default to last tag
gtd() {
  # get last tag
  ref=${@:-$(git describe --tags --abbrev=0 2>/dev/null)}
  if [ -z "$ref" ]; then
    echo "No tags found"
    return 1
  fi

  # confirm delete if last tag is inferred
  if [ $# -eq 0 ]; then
    confirm "Delete tag $ref? (y/n) "
    if [ "$?" -ne 0 ]; then
      return "$?"
    fi
  fi

  # delete local tag
  git tag --delete $ref
  if [ "$?" -ne 0 ]; then
    return "$?"
  fi

  # delete remote tag (if remote origin exists)
  git remote get-url origin >/dev/null 2>&1
  if [ "$?" -eq 0 ]; then
    git push --delete origin $ref
  fi
}

# git log --oneline
# default to 10
glo() {
  n=${@:--10}
  git log --oneline $n
}

# git log message only
# default to 10
glom() {
  n=${@:--10}
  message=$(git log --format=%s $n)
  echo -n $message
}
alias glom1="glom -1"
alias glom2="glom -2"
alias glom3="glom -3"
alias glom4="glom -4"
alias glom5="glom -5"

# show the changes of a specific commit
gdd() {
  ref=${@:-head}
  git diff $ref^ $ref
}

# push to the current branch's upstream
pushpr() {
  remote_fullname=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
  remote=$(echo $remote_fullname | cut -d'/' -f1)
  remote_branch=$(echo $remote_fullname | cut -d'/' -f2-)
  git push $remote HEAD:$remote_branch "$@"
}

# pull from current branch's upstream with --ff-only
ffpr() {
  remote_fullname=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
  remote=$(echo $remote_fullname | cut -d'/' -f1)
  remote_branch=$(echo $remote_fullname | cut -d'/' -f2-)
  local_branch=$(git_local_branch)
  git pull --ff-only $remote $remote_branch:$local_branch
}

# Apply a history-rewriting operation based on an active rebase, cherry-pick, merge, or revert
git_rewrite_history() {
  if [ -d ".git/rebase-merge" ] || [ -d ".git/rebase-apply" ]; then
    type="rebase"
  elif [ -f ".git/CHERRY_PICK_HEAD" ]; then
    type="cherry-pick"
  elif [ -f ".git/MERGE_HEAD" ]; then
    type="merge"
  elif [ -f ".git/REVERT_HEAD" ]; then
    type="revert"
  else
    echo "No rebase, cherry-pick, merge, or revert in progress."
    return 1
  fi

  GIT_EDITOR=true git $type "$@"
}

# continue
alias gcon="git_rewrite_history --continue"

## add all and continue
alias gac="git add -A && gcon"

# abort
alias gab="git_rewrite_history --abort"

# skip
alias gskip="git_rewrite_history --skip"

#-------------------------#
# npm
#-------------------------#

alias ni="npm install"
# if the dependency is already in devDependencies, --save is needed to add it to dependencies
alias nis="npm install --save"
alias niu="npm install && npm update"
alias nig="npm install --global"
alias nug="npm uninstall -g"
alias nu="npm update"
alias nv="npm view"
alias nisd="npm install --save-dev"
alias nun="npm uninstall"
alias nus="npm uninstall --save"
alias nusd="npm uninstall --save-dev"
alias npmo="npm outdated --depth=0"
alias nr="npm run"
alias ns="npm start"
alias nrr="npm run restart"
alias nbr="npm run build && npm run restart"
alias nst="npm run stop"
alias nt="npm test"
alias ntw="npm test -- --watch"
alias nre="npm repo"
alias nw="npm run watch || npx tsc --watch"
alias nb="npm run build"
alias nd="npm run dist"
alias nls="npm ls"
alias nbw="npm run build -- --watch"
alias l="npm run lint"
alias lint="npm run lint"
alias ll="npm run lint:src"
alias lf="npm run lint -- --fix"
alias lnt="npm run lint && npm run test"
alias st="standard"
alias stf="standard --fix"
alias nrd="npm run deploy && pusht"
alias nrs="npm run deploy:staging"
alias pi="pnpm install"
alias pa="pnpm add"

# yarn
alias y="yarn"
alias ya="yarn add"
alias yad="yarn add --dev"
alias yb="yarn build"
alias yr="yarn remove"
alias yt="yarn test"
alias ytp="yarn test:puppeteer"
alias yl="yarn link"
alias yu="yarn upgrade"
alias yul="yarn unlink"
alias yga="yarn global add"
alias ygr="yarn global remove"

# bun
alias ba="bun add"
alias bad="bun add --dev"
alias bag="bun add --global"
alias bb="bun run build"
alias bd="bun run dist"
alias bi="bun install"
alias big="bun install -g"
alias bs="bun start"
alias brm="bun remove"
alias brg="bun remove --global"
alias bl="bun link"
alias bt="bun test"
alias brt="bun run test"
# update all dependencies
alias bu="bun update"
# upgrade bun itself
alias bup="bun upgrade"

# bun run
# shows available scripts like npm run if no arguments are passed
br() {
  if [ $# -eq 0 ]; then
    # only echo the scripts section
    from="package.json scripts"
    to=Examples
    bunRunOutput="$(FORCE_COLOR=1 bun run)"
    truncated="$(echo "${bunRunOutput#*"$from"}" | tail -n +2)"
    scripts=$(echo "\n${truncated%%"$to"*}" | ghead -n -2)
    echo "$scripts\n" | sed "s/ bun run//g"
  else
    bun run "$@"
  fi

}

# bun watch or watch:ts
bw() {

  if [ ! -f package.json ]; then
    echo "No package.json"
    return 1
  fi

  jq -e .scripts.watch <package.json >/dev/null 2>&1
  if [ "$?" -eq 0 ]; then
    bun run watch
    return
  fi

  jq -e '.scripts["watch:ts"]' <package.json >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    bun run watch:ts
  else
    echo "No watch or watch:ts scripts found"
    return 1
  fi
}

# webpack bundle size
alias bph="bunx @grimmbraten/bundlephobia-cli"

# install size
alias pph="bunx packagephobia-cli"

# show a package's tags
dt() {
  npm view "$@" dist-tags
}

# npm view short
nvs() {
  underline=$(tput smul)
  yellow=$(tput setaf 3)
  cyan=$(tput setaf 6)
  gray=$(tput setaf 8)
  reset=$(tput sgr0)
  pkg=$(npm view --json "$@" name description homepage version time.modified)
  name=$(echo "$pkg" | jq -r ".name")
  description=$(echo "$pkg" | jq -r ".description")
  homepage=$(echo "$pkg" | jq -r ".homepage")
  version=$(echo "$pkg" | jq -r ".version")
  timeModified=$(echo "$pkg" | jq -r '."time.modified"' | date +%D)
  echo
  echo "$yellow$underline$name@$version$reset"
  if [ $timeModified != "null" ]; then
    echo "$gray$timeModified$reset"
  fi
  if [ $description != "null" ]; then
    echo $description
  fi
  if [ $homepage != "null" ]; then
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

# bump the version, push, and publish to latest
npub() {
  case $1 in
  major | minor | patch)
    npm version "$@" &&
      git push &&
      git push --no-verify --tags &&
      npm publish
    ;;
  # premajor:   1.0.0-0 → 2.0.0-0
  # preminor:   1.0.0-0 → 1.1.0-0
  # prepatch:   1.0.0-0 → 1.0.1-0
  # prerelease: 1.0.0-0 → 1.0.0-1
  premajor | preminor | prepatch | prerelease)
    npm version "$@" &&
      git push &&
      git push --no-verify --tags &&
      npm publish --tag next
    ;;
  *)
    echo "npub [major|minor|patch] to publish to latest" >&2
    echo "npub [premajor|preminor|prepatch|prerelease] to publish to next" >&2
    return 1
    ;;
  esac
}

# show files that will be published to npm
nf() {
  name=$(jq -r .name <package.json)
  version=$(jq -r .version <package.json)
  tarfile="$name-$version.tgz"
  npm pack
  tar -tzf $tarfile
  rm -rf $tarfile
}

#-------------------------#
# JSON
#-------------------------#

# parse a json file and output to less with syntax highlighting
# select a specific property by passing a jq selector as a second argument (outputs without less)
lo() {
  if [ $# -eq 0 ]; then
    echo "Please specify a json or markdown file"
    return 1
  fi

  EXT=$(echo $1 | sed 's/^.*\.//')

  case $EXT in

  # json
  json)
    if [ $# -eq 1 ]; then
      jq $2 -C <$1 | less -R
    else
      jq $2 -C <$1
    fi
    ;;

  # markdown
  md)
    # check that marked-terminal is installed
    # npx marked-terminal-cli is too slow, so install the global
    MARKED_TERMINAL_TYPE=$(type -af marked-terminal-cli)
    if [ "$MARKED_TERMINAL_TYPE" = "marked-terminal-cli not found" ]; then
      # printf 'Install marked-terminal-cli (y/n)? '
      # read -n 1 -p "Is this a good question (y/n)? " answer
      confirm "Install marked-terminal-cli (y/n)? "
      if [ "$?" -eq 1 ]; then
        return 1
      fi
      npm install -g marked-terminal-cli
    fi
    FORCE_COLOR=1 marked-terminal-cli "$1" | less -r
    ;;

  # other
  *)
    less $1
    ;;
  esac
}

# parse the package.json file and output to less with syntax highlighting
# select a specific property by passing a jq selector as an argument (outputs without less)
lp() {
  if [ $# -eq 0 ]; then
    jq <package.json -C | less -R
  else
    jq $@ <package.json
  fi
}

#-------------------------#
# Video Processing
#-------------------------#

# convert a video to an animated gif
togif() {
  if [ $# -lt 1 ]; then
    echo "Converts a video to a compressed, animated gif. Outputs to INPUT.MOV.gif"
    echo ""
    echo "Usage:"
    echo "togif input.mov"
  else
    ffmpeg -i "$@" -r 25 -f gif - | gifsicle --optimize=3 --lossy=90 --scale 0.5 --colors=32 >"$@.gif"
  fi
}

#-------------------------#
# Key Bindings
#-------------------------#

set show-all-if-ambiguous on
set completion-ignore-case on
set editing-mode vi

# key bindings are defined in ~/.zhrc and ~/.inputrc
# http://stackoverflow.com/questions/23349325/inputrc-override-controlw
set bind-tty-special-chars Off

#-------------------------#
# Miscellaneous
#-------------------------#

PROMPT="%F{yellow}%n%f%F{cyan}[%1~]%# %f"

# added by travis gem
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh

# fnm
# Note, you may need to explicitly specify the architecture for ARM-based Mac M1:
#   fnm install --arch=arm64 VERSION
# Run `node -p process.platform` to verify.
[ -x $(command -v fnm) ] && eval "$(fnm env --use-on-cd)"
