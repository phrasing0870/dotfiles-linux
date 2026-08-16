#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$DOTFILES_DIR"

echo "Updating APT..."
sudo apt update

echo "Installing packages..."
sudo xargs -a packages/apt.txt apt install -y

echo "Installing Flatpaks..."
while read -r app; do
    [ -z "$app" ] && continue
    flatpak install -y flathub "$app"
done < packages/flatpak.txt

echo "Linking dotfiles..."
stow -R -t "$HOME" bash git

echo
echo "Setup complete."
