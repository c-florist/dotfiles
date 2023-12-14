# System helpers
alias lsapt="comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)"

# Golang
alias got="go test -v"
alias gotc="go test -v -cover"
