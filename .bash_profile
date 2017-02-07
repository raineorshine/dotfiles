export PATH=$HOME/local/bin:$PATH
export PATH="/usr/local/heroku/bin:$PATH"
export PATH="/Library/Frameworks/Python.framework/Versions/3.3/bin:${PATH}"
export PATH="~/bin:$PATH"
export PATH="./node_modules/.bin:$PATH"
export PATH="$HOME/Library/Haskell/bin:$PATH"
export PATH=".cabal-sandbox/bin:$PATH"

export EDITOR='subl -w'

# bashrcgenerator.com
# e.g. name[pwd]$
export PS1="\[\e[00;33m\]\u\[\e[0m\]\[\e[00;36m\][\W]\$\[\e[0m\]\[\e[00;37m\] \[\e[0m\]"

# display working directory as title
export PS1="$PS1\[\e]0;\w\a\]"

export HISTCONTROL=ignoredups
export HISTIGNORE="ls:pwd:gs:gulp:gd:push:pull:p"

export NVM_DIR="/Users/raine/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[[ -r $NVM_DIR/bash_completion ]] && . $NVM_DIR/bash_completion

if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
