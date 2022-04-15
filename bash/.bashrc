# -------------------
# ---- DEFAULTS -----
# -------------------

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History controls
# Don't duplicate lines
HISTCONTROL=ignoreboth
# File size
HISTSIZE=1000
HISTFILESIZE=2000
# Append to history
shopt -s histappend

# Make less more user-friendly
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Add an "alert" alias for long running commands.
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# -------------------
# ---- SETTINGS -----
# -------------------

# Allow directory variables
shopt -s cdable_vars
# Adjust window size if necessary
shopt -s checkwinsize

# asdf settings
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

# -------------------
# ---- VARIABLES ----
# -------------------

# Dev directories
export devp=~/dev/projects
export devl=~/dev/learning

# -------------------
#  ALIASES & BINDINGS
# -------------------

# Git
alias gdiff='git difftool -y -x "colordiff -y -W $COLUMNS" | less -R'
alias gs='git status'
alias gp='git push'
alias gall='git add -A'

# Shell
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Python
alias venv='source .venv/bin/activate'
alias mkvenv='python -m venv .venv'

# -------------------
# ---- FUNCTIONS ----
# -------------------

# Go up n directories
function up() {
    cd "$(eval printf '../'%.0s "{1..$1}")" && pwd
}

# Check a command in the cheatsheet
function cheat() {
    curl cheatsheet.sh/$1
}

# Extract from common archive types
function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Make a new dir and initialise git
function gitdir() {
    mkdir -p "$@" && cd "$@"
    git init
}


# Hook direnv into shell - Needs to be at the end.
eval "$(direnv hook bash)"