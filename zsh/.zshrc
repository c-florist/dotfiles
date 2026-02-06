# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(git docker z mise direnv)
ZSH_THEME="dst"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"
source $ZSH/oh-my-zsh.sh
zstyle ':omz:update' mode reminder

# History
export HISTSIZE=10000
export SAVEHIST=$HISTSIZE
export HISTDUP=erase
export HISTORY_IGNORE="(ls|wf|fg)"
export HISTFILE="$CONFIG/zsh/.zsh_history"

setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt SHARE_HISTORY             # Share history between all sessions.

export DOTFILES_PATH="$HOME/dev/dotfiles"

source $DOTFILES_PATH/omz/aliases.zsh
source $DOTFILES_PATH/omz/functions.zsh

export PATH="$HOME/.local/bin:$DOTFILES_PATH/bin:$PATH"

# mise-en-place
eval "$(~/.local/bin/mise activate zsh)"

# Golang
# export GOPATH=$(go env GOPATH)
# export PATH=$PATH:$GOPATH/bin

# MacOS
## Add libpq to PATH
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

fpath+=~/.zfunc; autoload -Uz compinit; compinit

