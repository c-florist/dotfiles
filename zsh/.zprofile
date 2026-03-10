## Ensure gnpug works
GPG_TTY=$(tty)
export GPG_TTY
## Add mise shims to path
export PATH="$HOME/.local/share/mise/shims:$PATH"

# macOS-only
if [[ "$OSTYPE" == "darwin"* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    ## Source gcloud and enable completions
    # source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
    # source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
    ## Use colima hosted docker daemon
    export DOCKER_HOST=unix:///Users/cflowers/.colima/default/docker.sock
fi
