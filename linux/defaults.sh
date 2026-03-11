#!/bin/bash

# GNOME desktop defaults for a dev-friendly setup.
# Run once on a fresh install, then log out and back in for all changes to take effect.
# Requires: gsettings (GNOME), dconf

set -e

# Check for GNOME
if ! command -v gsettings &>/dev/null; then
    echo "gsettings not found - this script is for GNOME desktops only."
    exit 1
fi

echo "Applying GNOME defaults..."

# ----------------------------------------
# Keyboard
# ----------------------------------------

# Fast key repeat rate (ms between repeats, lower = faster; default ~30)
gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 20

# Short delay before repeat starts (ms; default ~500)
gsettings set org.gnome.desktop.peripherals.keyboard delay 200

# ----------------------------------------
# Touchpad
# ----------------------------------------

# Tap to click
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

# Natural scrolling
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false

# ----------------------------------------
# File manager (Nautilus)
# ----------------------------------------

# Default to list view
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'

# Sort folders before files
gsettings set org.gnome.nautilus.preferences default-sort-order 'name'
dconf write /org/gtk/settings/file-chooser/sort-directories-first true 2>/dev/null || true

# ----------------------------------------
# Window management
# ----------------------------------------

# Focus follows click (not hover)
gsettings set org.gnome.desktop.wm.preferences focus-mode 'click'

# Attach modal dialogs to parent window
gsettings set org.gnome.mutter attach-modal-dialogs true

# ----------------------------------------
# Privacy / UX
# ----------------------------------------

# Disable hot corner (top-left activities trigger)
gsettings set org.gnome.desktop.interface enable-hot-corners false

# Show weekday in clock
gsettings set org.gnome.desktop.interface clock-show-weekday true

# Dark theme
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

echo "Done! Some changes may require a logout to take effect."
