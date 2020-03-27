export PATH="$HOME/Library/Haskell/bin:$PATH"
export PATH="./node_modules/.bin:$PATH"
export PATH=".cabal-sandbox/bin:$PATH"
export PATH="/Library/Frameworks/Python.framework/Versions/3.3/bin:${PATH}"
export PATH="/usr/local/heroku/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="~/bin:$PATH"
export PATH=$HOME/local/bin:$PATH

export TZ='America/Denver'

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

# previous bash_completion
# not sure which one is better
#
# [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

# [ -f ~/.gpg-agent-info ] && source ~/.gpg-agent-info
# if [ -S "${GPG_AGENT_INFO%%:*}" ]; then
#   export GPG_AGENT_INFO
# else
#   eval $( gpg-agent --daemon ~/.gpg-agent-info )
# fi

if [ -f ~/.bashrc ]; then
  source ~/.bashrc

  # autocomplete git alises
  source /usr/local/etc/alias_completion
  unset -f alias_completion
fi
