export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="dst"

# Auto-update behaviour
zstyle ':omz:update' mode reminder

COMPLETION_WAITING_DOTS="true"

HIST_STAMPS="yyyy-mm-dd"

plugins=(git asdf direnv pip python docker npm)

source $ZSH/oh-my-zsh.sh

# mise-en-place
eval "$(~/.local/bin/mise activate zsh)"

# Golang
# export GOPATH=$(go env GOPATH)
# export PATH=$PATH:$GOPATH/bin

# MacOS
## Add libpq to PATH
# export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
