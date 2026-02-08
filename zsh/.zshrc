# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(git docker z mise direnv fzf kubectl)
ZSH_THEME="dst"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"
source $ZSH/oh-my-zsh.sh
zstyle ':omz:update' mode reminder

# History
export HISTORY_IGNORE="(ls|wf|fg)"
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.

export DOTFILES_PATH="$HOME/dev/dotfiles"

export PATH="$HOME/.local/bin:$DOTFILES_PATH/bin:$PATH"

# fzf - Catppuccin Frappe colors + preview configuration
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
  --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
  --color=marker:#a6d189,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 \
  --color=selected-bg:#51576d \
  --height=60% --layout=reverse --border"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}' --preview-window=right:50%"
export FZF_ALT_C_OPTS="--preview 'tree -C -L 2 {}' --preview-window=right:50%"

# mise-en-place
eval "$(~/.local/bin/mise activate zsh)"

# Kitty shell integration
if [[ "$TERM" == "xterm-kitty" ]]; then
    autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
    kitty-integration
    unfunction kitty-integration
fi

# MacOS
## Add libpq to PATH
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

fpath+=~/.zfunc; autoload -Uz compinit; compinit

[ -f "$HOME/.zshrc_workshell" ] && source "$HOME/.zshrc_workshell"
