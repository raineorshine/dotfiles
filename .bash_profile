# .bash_profile
# This is loaded whenever a login shell is opened. It can safely be loaded in ssh environments.
# .profile, .zprofile, and .bash_profile should only contain environment variables. Everything else goes in .bashrc.

export PATH="./node_modules/.bin:$PATH"
export PATH=".cabal-sandbox/bin:$PATH"
export PATH="/usr/local/opt/python3/libexec/bin:$PATH"
export PATH="/usr/local/heroku/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="~/bin:$PATH"
export PATH="~/local/bin:$PATH"

export EDITOR='code'
export GIT_EDITOR='vim'
export HISTCONTROL=ignoredups
export HISTIGNORE="ls:pwd:gs:gulp:gd:push:pull:p"
export TZ='America/New York'