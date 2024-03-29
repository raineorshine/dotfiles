# .zprofile
# NOTE: This file should only contain commands that do not work in a bash environment. Prefer .bash_profile.
# This is loaded whenever a login shell is opened.
# .profile, .zprofile, and .bash_profile should only contain environment variables. Everything else goes in .bashrc.
# Put aliases, functions, and most everything except environment variables here.

source ~/.bash_profile

export PATH="~/Library/pnpm:$PATH"
export PATH="~/Library/Haskell/bin:$PATH"
export PATH="/Library/Frameworks/Python.framework/Versions/3.3/bin:${PATH}"
