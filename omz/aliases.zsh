# Git
alias gswl='git switch $(git_main_branch) && git pull'

# Unix
alias lsapt="comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)"
alias ls="ls -A -F --color=always"
alias dirsize="du -sh * 2>/dev/null | sort -hr | head -n10"
alias gpgk='gpgconf --kill gpg-agent && gpgconf --launch gpg-agent'
alias asl='aws sso login'
alias nosleep='caffeinate -d'

# Tooling
alias j="just"
alias tf="terraform"
alias cat="bat -p --no-paging --theme=gruvbox-dark"
alias mr="mise run"
alias k="kubectl"

# Python
## Django
alias sp="python manage.py shell_plus"
