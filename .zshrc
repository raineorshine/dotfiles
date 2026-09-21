# .zhrc
# NOTE: This file should only contain commands that do not work in a bash environment. Prefer .bashrc.
# This is loaded whenever an interactive shell is opened.
# .bashrc and .zshrc can contain aliases, functions, and most anything except environment variables.

# Drop aliases that shadow .bashrc functions of the same name before re-sourcing.
# Without this, re-sourcing (`so`) expands the alias inside `pr() {` in .bashrc,
# which zsh rejects with "defining function based on alias".
unalias pr 2>/dev/null

source ~/.bashrc

so() {
  source $dothome/.zshrc
}

alias brave="open -a Brave\ Browser"
alias chrome="open -a Google\ Chrome"
alias preview="open -a Preview"

# Allow pasting an unquoted GitHub PR URL with a query string (e.g. .../changes?diff=unified),
# which zsh would otherwise treat as a failed glob ("no matches found").
alias pr="noglob pr"

# browse the home page of an npm module
nbro() {
  if [[ $# -eq 0 && ! -f package.json ]]; then
    echo "nbro: no package.json in the current directory; specify a module name (e.g. nbro react)" >&2
    return 1
  fi
  npm view "$@" homepage | xargs open
}

#-------------------------#
# fnm
#-------------------------#

# Wrap fnm to add a `migrate` subcommand that reinstalls global npm packages
# from one Node version onto another after upgrading Node:
#   fnm migrate [from-node] [to-node]
#     fnm migrate          migrate previous installed version -> current version
#     fnm migrate 24       migrate newest installed version below 24 -> 24
#     fnm migrate 22 24    migrate 22 -> 24
# Interactively choose which packages to install. Everything is selected by
# default, so pressing Enter installs all of them. Packages that are already
# installed on the target version are listed but not offered.
# Registry packages are installed with `npm install -g`; linked packages
# (npm link) are re-linked from ~/projects/<name>. Corepack is then enabled on
# the target to recreate the yarn/pnpm shims, installing corepack first on
# Node >=25 (which no longer bundles it). Set FNM_MIGRATE_DRYRUN=1 to print
# what would happen without making changes. All other fnm subcommands are
# passed through to the real fnm binary.
fnm() {
  if [[ "$1" == migrate ]]; then
    shift
    _fnm_migrate_globals "$@"
  else
    command fnm "$@"
  fi
}

_fnm_migrate_globals() {
  emulate -L zsh
  setopt local_options local_traps

  local from to
  case $# in
    0) to="$(command fnm current 2>/dev/null)" ;;
    1) to="$1" ;;
    *) from="$1"; to="$2" ;;
  esac
  if [[ -z "$to" || "$to" == none || "$to" == system ]]; then
    print -u2 "Usage: fnm migrate [from-node] [to-node]"
    return 1
  fi

  # resolve the target to a full version so we can find the version just below it
  local to_full
  to_full="$(command fnm exec --using "$to" node -v 2>/dev/null)" || {
    print -u2 "Unknown target Node version: $to"
    return 1
  }

  # default `from` to the newest installed version below the target
  if [[ -z "$from" ]]; then
    from="$(command fnm ls 2>/dev/null | command grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' \
      | { cat; print -r -- "$to_full"; } | sort -V -u \
      | awk -v t="$to_full" '$0==t{print prev; exit} {prev=$0}')"
    if [[ -z "$from" ]]; then
      print -u2 "No installed Node version found below $to_full to migrate from."
      return 1
    fi
  fi

  from="${from#v}"; to="${to#v}"

  print "Reading globals from Node $from..."
  local from_json to_json
  from_json="$(command fnm exec --using "$from" npm ls -g --depth=0 --json 2>/dev/null)" || {
    print -u2 "Failed to read globals from Node $from"
    return 1
  }
  to_json="$(command fnm exec --using "$to" npm ls -g --depth=0 --json 2>/dev/null)"

  # names (and versions) already installed on the target version
  local -A on_target
  local line
  for line in ${(f)"$(print -r -- "$to_json" | jq -r '
      .dependencies // {} | to_entries[] | "\(.key)\t\(.value.version // "?")"')"}; do
    [[ -z "$line" ]] && continue
    on_target[${line%%$'\t'*}]="${line#*$'\t'}"
  done

  # parse source globals into parallel arrays, splitting out already-installed ones
  local -a sel_key sel_type sel_link sel_ver sel_on
  local -a done_key done_ver
  for line in ${(f)"$(print -r -- "$from_json" | jq -r '
      .dependencies // {}
      | to_entries[]
      | [ (if ((.value.resolved // "") | startswith("file:")) then "link" else "registry" end),
          .key,
          (if ((.value.resolved // "") | startswith("file:")) then (.value.resolved | sub("^file:"; "") | split("/") | last) else .key end),
          (.value.version // "?")
        ] | join(" ")')"}; do
    [[ -z "$line" ]] && continue
    local -a f=(${=line})
    local t="$f[1]" k="$f[2]" lk="$f[3]" v="$f[4]"
    if [[ -n "${on_target[$k]+x}" ]]; then
      done_key+=("$k"); done_ver+=("${on_target[$k]}")
    else
      sel_key+=("$k"); sel_type+=("$t"); sel_link+=("$lk"); sel_ver+=("$v"); sel_on+=(1)
    fi
  done

  local nsel=${#sel_key}
  if (( nsel == 0 )); then
    if (( ${#done_key} )); then
      local g=$'\e[32m' d=$'\e[2m' r=$'\e[0m' j
      print "\n${d}Installed:${r}"
      for (( j=1; j<=${#done_key}; j++ )); do
        print -r -- "  ${g}✓${r} ${d}$done_key[j]${r}"
      done
      print "\nAll ${#done_key} global package(s) are already installed on Node $to."
    else
      print "No global packages found."
    fi
    return 0
  fi

  # interactive multi-select (skipped when not attached to a terminal)
  local cancelled=0
  if [[ -t 0 && -t 1 ]]; then
    local bold=$'\e[1m' dim=$'\e[2m' green=$'\e[32m' cyan=$'\e[36m' reset=$'\e[0m'
    local cur=1 painted=0 nlines=0 i
    local -a out
    local marker pointer name disp nsp e spc l key rest anyoff x
    print -n $'\e[?25l'
    trap 'print -n $'\''\e[?25h'\''; return 130' INT
    while true; do
      out=( "${bold}Migrate globals: Node $from → Node $to${reset}"
            "${dim}↑/↓ move · space toggle · a all · enter install · q cancel${reset}" )
      if (( ${#done_key} )); then
        out+=( "" "${dim}Installed:${reset}" )
        for (( i=1; i<=${#done_key}; i++ )); do
          out+=( "  ${green}✓${reset} ${dim}$done_key[i]${reset}" )
        done
      fi
      out+=( "" "${cyan}Migrate:${reset}" )
      for (( i=1; i<=nsel; i++ )); do
        if (( sel_on[i] )); then marker="${green}◉${reset}"; else marker="${dim}◯${reset}"; fi
        if (( i == cur )); then pointer="${green}❯${reset}"; else pointer=" "; fi
        name="$sel_key[i]"; disp="$sel_key[i]"
        if [[ "$sel_type[i]" == link ]]; then name="$name ${dim}(link)${reset}"; disp="$disp (link)"; fi
        nsp=$(( 34 - ${#disp} )); (( nsp < 1 )) && nsp=1
        e=""; spc="${(l:$nsp:)e}"
        out+=( "  $pointer $marker $name$spc${dim}$sel_ver[i]${reset}" )
      done
      (( painted )) && print -n "\e[${nlines}A"
      print -n $'\e[J'
      for l in "$out[@]"; do print -r -- "$l"; done
      nlines=${#out}; painted=1

      IFS= read -rsk1 key
      case "$key" in
        $'\e')
          IFS= read -rsk2 rest
          case "$rest" in
            '[A'|'OA') if (( cur > 1 )); then (( cur-- )); else cur=$nsel; fi ;;
            '[B'|'OB') if (( cur < nsel )); then (( cur++ )); else cur=1; fi ;;
          esac ;;
        k) if (( cur > 1 )); then (( cur-- )); else cur=$nsel; fi ;;
        j) if (( cur < nsel )); then (( cur++ )); else cur=1; fi ;;
        ' ') sel_on[cur]=$(( ! sel_on[cur] )) ;;
        a)
          anyoff=0
          for (( x=1; x<=nsel; x++ )); do (( sel_on[x] )) || anyoff=1; done
          for (( x=1; x<=nsel; x++ )); do sel_on[x]=$anyoff; done ;;
        q) cancelled=1; break ;;
        $'\n'|$'\r'|'') break ;;
      esac
    done
    print -n $'\e[?25h'
  fi

  if (( cancelled )); then
    print "Cancelled."
    return 0
  fi

  # collect the chosen packages
  local -a inst link_names i
  for (( i=1; i<=nsel; i++ )); do
    (( sel_on[i] )) || continue
    if [[ "$sel_type[i]" == link ]]; then
      link_names+=("$sel_link[i]")
    else
      inst+=("$sel_key[i]")
    fi
  done

  if (( ${#inst} == 0 && ${#link_names} == 0 )); then
    print "Nothing selected."
    return 0
  fi

  local dry="${FNM_MIGRATE_DRYRUN:-}"
  if (( ${#inst} )); then
    print "\nInstalling on Node $to: ${inst[*]}"
    if [[ -n "$dry" ]]; then
      print "DRYRUN: fnm exec --using $to npm install -g ${inst[*]}"
    else
      command fnm exec --using "$to" npm install -g "$inst[@]"
    fi
  fi

  if (( ${#link_names} )); then
    print "\nRe-linking on Node $to:"
    local proj dir
    for proj in "$link_names[@]"; do
      dir="$HOME/projects/$proj"
      if [[ ! -d "$dir" ]]; then
        print -u2 "Skipping $proj: $dir not found"
        continue
      fi
      print "==> npm link in $dir"
      if [[ -n "$dry" ]]; then
        print "DRYRUN: (cd $dir && fnm exec --using $to npm link)"
      else
        ( cd "$dir" && command fnm exec --using "$to" npm link )
      fi
    done
  fi

  # Recreate yarn/pnpm shims on the target via corepack. Node no longer bundles
  # corepack as of v25, so install it first when the target lacks it. Pin the
  # install directory to the target's own bin (via node's execPath) so the shims
  # can't land on another version through PATH fallthrough.
  print "\nEnabling corepack (yarn/pnpm) on Node $to..."
  if [[ -n "$dry" ]]; then
    print "DRYRUN: fnm exec --using $to sh -c 'install corepack if missing; corepack enable --install-directory <to-bin>'"
  else
    if command fnm exec --using "$to" sh -c '
        bin=$(dirname "$(node -p process.execPath)")
        [ -x "$bin/corepack" ] || npm install -g corepack || exit 1
        corepack enable --install-directory "$bin"
      '; then
      print ">> corepack enabled"
    else
      print -u2 ">> corepack setup failed"
    fi
  fi
}

notify() {
  local title="${2:+$1}"
  local message="${2:-$*}"
  /usr/bin/osascript -e "display notification \"$message\" with title \"${title:-Notification}\""
}

# icloud directory
ic() {
  pushd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Documents &> /dev/null
  ls
}

# project directory
p() {
  local n=${1:-10}
  pushd ~/projects &> /dev/null
  ls -AGFplht --color=always | grep -v .DS_Store | tail +2 | head -n "$n"
  echo ...
}

# This file contains only zsh bindings. bash bindings are in .inputrc.
# Show all commands available in zsh for key binding: zle -al
# More info about key bindings: https://unix.stackexchange.com/questions/116562/key-bindings-table?rq=1

bindkey "\C-h" backward-char
# kills tab-completion!
# bindkey "\C-i" forward-char
bindkey "\C-b" backward-word
# ^? is backspace, but it does not work with the Control key for some reason
# bindkey "\C-^?" backward-kill-word
bindkey "\C-v" backward-kill-word
bindkey "\C-w" forward-word
bindkey "\C-f" kill-word
bindkey "\C-a" end-of-line

# Control + number does not work for some reason
bindkey "\C-h" beginning-of-line

# display "✓" on right side if error code 0, otherwise display "✗"
# Only enable right prompt in iTerm, not VS Code/Copilot terminals.
# Otherwise it causes run_in_terminal sync mode output to be blank.
if [[ -o interactive && "$TERM_PROGRAM" == "iTerm.app" ]]; then
  RPROMPT="%(?.%F{green}✓%f.%F{red}✗%f)"
fi

# strip rprompt checkmark
# useful for copying the shell output to a github issue
alias stripr=sed 's/\w*✓//'

# timestamp
# RPROMPT="%*"

# set window title to current working directory after returning from a command
precmd() { echo -ne "\e]1;${PWD##*/}\a"; }

#-------------------------#
# dotfiles
#-------------------------#

# add, commit, and push to dotfiles repo
dm() {
  local dir=$(pwd)
  cd "$dothome"
  trap "cd \"$dir\"" EXIT

  so &&
  gam "$@" &&
  git push
}

# add, amend, and force push to dotfiles repo
daforce() {
  local dir=$(pwd)
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
  local dir=$(pwd)
  cd "$dothome"

  git --no-pager diff --exit-code --color=always ||
  echo -e "\nRun 'dm' to commit dotfile changes"

  cd "$dir"
}

#-------------------------#
# Karabiner
#-------------------------#

# edit karabiner.json
kar() {
  kardiff
  $EDITOR ~/.config/karabiner/karabiner.json
}

# pushd to ~/.config/karabiner
kardir() {
  kardiff
  pushd ~/.config/karabiner
}

# diff karabiner-config
kardiff() {
  local dir=$(pwd)
  cd ~/.config/karabiner
  git --no-pager diff
  cd "$dir"
}

# pull karabiner-config
karpull() {
  local dir=$(pwd)
  cd ~/.config/karabiner
  git pull
  cd "$dir"
}

#-------------------------#
# Text Replacements
#-------------------------#

# Manage macOS System Settings > Keyboard > Text Replacements from the shell.
# add/rm go through keyboardservicesd (bin/ksreplace.swift, compiled on first
# use), the same path the settings pane uses, so changes are stored, synced to
# iCloud, and picked up by running apps immediately. ls reads the daemon's
# sqlite store directly.
#   textreplace ls           list from<TAB>to
#   textreplace add FROM TO  add
#   textreplace rm FROM      remove
textreplace() {
  local db=~/Library/KeyboardServices/TextReplacements.db to
  case $1 in
    ls) sqlite3 -separator $'\t' "$db" \
          "select ZSHORTCUT, ZPHRASE from ZTEXTREPLACEMENTENTRY where ZWASDELETED=0 order by ZSHORTCUT;" ;;
    add) [[ -n $2 && -n $3 ]] || { echo "usage: textreplace add FROM TO" >&2; return 1 }
      _ksreplace add "$2" "$3" && echo "Added: $2 → $3" ;;
    rm) [[ -n $2 ]] || { echo "usage: textreplace rm FROM" >&2; return 1 }
      to=$(sqlite3 "$db" "select ZPHRASE from ZTEXTREPLACEMENTENTRY where ZWASDELETED=0 and ZSHORTCUT='${2//\'/''}' limit 1;")
      [[ -n $to ]] || { echo "not found: $2" >&2; return 1 }
      _ksreplace rm "$2" "$to" && echo "Removed: $2" ;;
    *) echo "usage: textreplace ls | add FROM TO | rm FROM" >&2; return 1 ;;
  esac
}

# run bin/ksreplace.swift, compiling it into the cache when missing or stale
_ksreplace() {
  local src=$dothome/bin/ksreplace.swift bin=~/.cache/dotfiles/ksreplace
  if [[ ! -x $bin || $src -nt $bin ]]; then
    mkdir -p "${bin:h}"
    swiftc -O -o "$bin" "$src" || return 1
  fi
  "$bin" "$@"
}

#-------------------------#
# gpg
#-------------------------#

alias gpg="gpg2 -o -"
alias pri="gpg -d ~/Google\ Drive/Finance/Accounts/private.json.asc | less"

# encrypt a file and save it as .asc (text) or .gpg (binary)
# requires "brew install gnupg"
gpge() {
if [ -z "$1" ]; then
    echo "Encrypt a file and save it as .asc (text) or .gpg (binary)"
    echo "\nUsage: gpge <filename>"
    echo "\nExamples:"
    echo "  gpge test.txt -> test.txt.asc"
    echo "  gpge test.jpg -> test.jpg.gpg"
    return 1
  fi

  local input_file="$1"
  local output_file
  local ext

  # Detect if file is a text file
  if file "$input_file" | grep -q 'text'; then
    gpg -ear raine --output "${input_file}.asc" "$input_file"
    echo "Encrypted: ${input_file}.asc"
  else
    gpg -er raine --output "${input_file}.gpg" "$input_file"
    echo "Encrypted: ${input_file}.gpg"
  fi
}

# decrypt a file and save it without the .asc or .gpg extension
gpgd() {
if [ -z "$1" ]; then
    echo "Decrypt a file and save it without the .asc or .gpg extension"
    echo "\nUsage: gpgd <filename>"
    echo "\nExamples:"
    echo "  gpgd test.txt.asc -> test.txt"
    echo "  gpgd test.jpg.gpg -> test.jpg"
    return 1
  fi

  local input_file="$1"
  local output_file
  local ext

  # Detect if file is a text file
  if file "$input_file" | grep -q 'text'; then
    output_file="${input_file%.asc}"
  else
    output_file="${input_file%.gpg}"
  fi

  gpg -d --output "$output_file" "$input_file"
  echo "Decrypted: $output_file"
}

# decrypt a file and preview with either less or Preview.app
gpgp() {
  local file="$1"
  if [[ "$file" == *.asc ]]; then
    gpg "$file" | less
  elif [[ "$file" == *.gpg ]]; then
    # http://apple.stackexchange.com/questions/175977/preview-image-from-pipe/175981#175981
    # man open | grep -C 3 "\-f"
    gpg -o - "$file" | open -a Preview.app -f
  else
    echo "Unsupported file type. Please provide a .asc or .gpg file."
    return 1
  fi
}

# encrypt ascii armored and pipe to stdout
# e.g. gpga < file.txt > file.txt.asc
gpga() {
  gpg -ear raine
}

# bun completions
[ -s "/Users/raine/.bun/_bun" ] && source "/Users/raine/.bun/_bun"

# completion
fpath+=~/.zcompletions
autoload -Uz compinit && compinit

# Claude Code (native install)
export PATH="$HOME/.local/bin:$PATH"

# Clear only the iTerm2 Hotkey Window prompt after 15 idle minutes.
# TMOUT alone measures time since the prompt, so track editing activity too.
# Leave running commands, partial input, and continuation prompts untouched.
if [[ -o interactive && "$TERM_PROGRAM" == iTerm.app && "$ITERM_PROFILE" == "Hotkey Window" ]]; then
  zmodload zsh/datetime
  autoload -Uz add-zle-hook-widget
  typeset -gi _iterm_idle_seconds=900 _iterm_last_activity=$EPOCHSECONDS

  _iterm_idle_activity() {
    _iterm_last_activity=$EPOCHSECONDS
  }
  add-zle-hook-widget line-init _iterm_idle_activity
  add-zle-hook-widget line-pre-redraw _iterm_idle_activity

  TRAPALRM() {
    local remaining
    TMOUT=$_iterm_idle_seconds
    zle || return 0
    remaining=$(( _iterm_idle_seconds - EPOCHSECONDS + _iterm_last_activity ))
    if (( remaining > 0 )); then
      TMOUT=$remaining
      return 0
    fi
    [[ -z $BUFFER && $CONTEXT == start ]] || return 0
    builtin cd -- "$HOME" || return 0
    _iterm_last_activity=$EPOCHSECONDS
    # Clear the visible screen; retain scrollback and command history.
    print -n -- $'\e[2J\e[H'
    print -n -- "\e]1;${PWD##*/}\a"
    zle reset-prompt
    zle -R
    return 0
  }
  TMOUT=$_iterm_idle_seconds
elif (( $+functions[_iterm_idle_activity] )); then
  # Disable the old all-iTerm hook when reloading an ordinary window.
  TMOUT=0
  add-zle-hook-widget -d line-init _iterm_idle_activity
  add-zle-hook-widget -d line-pre-redraw _iterm_idle_activity
  unfunction TRAPALRM _iterm_idle_activity
  unset _iterm_idle_seconds _iterm_last_activity
fi
