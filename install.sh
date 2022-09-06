#!/usr/bin/env bash

cp "$(pwd)/setup/ubuntu/pkg.list" "$HOME"

"$HOME/pkg.list" | xargs apt install -y

rm "$HOME/pkg.list"
