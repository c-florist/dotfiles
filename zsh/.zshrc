# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(git docker z mise)
ZSH_THEME="dst"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"
source $ZSH/oh-my-zsh.sh
zstyle ':omz:update' mode reminder

export DOTFILES_PATH="$HOME/dotfiles"

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
# export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
