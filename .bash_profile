# .bash_profile
# This is loaded whenever a login shell is opened. It can safely be loaded in ssh environments.
# .profile, .zprofile, and .bash_profile should only contain environment variables. Everything else goes in .bashrc or .zshrc.

export BUN_INSTALL="$HOME/.bun"
export EDITOR='code'
export GIT_EDITOR='vim'
export HISTCONTROL=ignoredups
export HISTIGNORE="ls:pwd:gs:gulp:gd:push:pull:p"
export TZ='America/New York'
export PKG_CONFIG_PATH="/usr/local/opt/postgresql@15/lib/pkgconfig"
export FNM_DIR="$HOME/.fnm"

export PATH=".cabal-sandbox/bin:$PATH"
export PATH="/usr/local/opt/python3/libexec/bin:$PATH"
export PATH="/usr/local/heroku/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="~/bin:$PATH"
export PATH="~/local/bin:$PATH"
export PATH="/Users/raine/Library/pnpm:$PATH"
export PATH="/usr/local/opt/postgresql@15/bin:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="/Users/raine/Library/Application Support/fnm:$PATH"
export PATH="$HOME/.docker/bin:$PATH"
export PATH="$HOME/.fnm:$PATH"

# local node_modules should take precedence over global modules
export PATH="./node_modules/.bin:$PATH"
