# .bash_profile
# This is loaded whenever a login shell is opened. It can safely be loaded in ssh environments.
# .profile, .zprofile, and .bash_profile should only contain environment variables. Everything else goes in .bashrc or .zshrc.

export BUN_INSTALL="$HOME/.bun"
export EDITOR='code'
export GIT_EDITOR='vim'
export HISTCONTROL=ignoredups
export HISTIGNORE="ls:pwd:gs:gulp:gd:push:pull:p"
export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@15/lib/pkgconfig"
export FNM_DIR="$HOME/.fnm"
# Download native Apple Silicon (arm64) Node builds instead of x64 under Rosetta.
export FNM_ARCH=arm64

# Homebrew (arm64, /opt/homebrew). Must come before the prepends below so they win over it.
eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH=".cabal-sandbox/bin:$PATH"
export PATH="/opt/homebrew/opt/python3/libexec/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/local/bin:$PATH"
export PATH="/Users/raine/Library/pnpm:$PATH"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
# old fnm path did not work with vercel because of space in "Application Support"
# export PATH="/Users/raine/Library/Application Support/fnm:$PATH"
export PATH="$HOME/.fnm:$PATH"
export PATH="$HOME/.docker/bin:$PATH"

# local node_modules should take precedence over global modules
export PATH="./node_modules/.bin:$PATH"
. "$HOME/.cargo/env"
