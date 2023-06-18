# .bash_profile
# This is loaded whenever a login shell is opened. It can safely be loaded in ssh environments.
# .profile, .zprofile, and .bash_profile should only contain environment variables. Everything else goes in .bashrc.

export PATH="$HOME/Library/Haskell/bin:$PATH"
export PATH="./node_modules/.bin:$PATH"
export PATH=".cabal-sandbox/bin:$PATH"
export PATH="/Library/Frameworks/Python.framework/Versions/3.3/bin:${PATH}"
export PATH="/usr/local/opt/python3/libexec/bin:$PATH"
export PATH="/usr/local/heroku/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="~/bin:$PATH"
export PATH=$HOME/local/bin:$PATH
export PATH="/Users/raine/Library/pnpm:$PATH"

export EDITOR='code'
export GIT_EDITOR='vim'
export HISTCONTROL=ignoredups
export HISTIGNORE="ls:pwd:gs:gulp:gd:push:pull:p"
export TZ='America/New York'

# load nvm and switch to default alias (slow)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[[ -r $NVM_DIR/bash_completion ]] && \. $NVM_DIR/bash_completion
