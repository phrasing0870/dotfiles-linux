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

echo "Installing yt-dlp..."
mkdir -p "$HOME/.local/bin"

curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
  -o "$HOME/.local/bin/yt-dlp"

chmod +x "$HOME/.local/bin/yt-dlp"

echo "Linking dotfiles..."
stow -R -t "$HOME" bash git

echo "Configuring firewall..."
sudo ufw allow 53317/tcp
sudo ufw allow 53317/udp

echo "Restoring Cinnamon settings..."
dconf load /org/cinnamon/ < cinnamon.dconf

echo "Restoring Nemo settings..."
dconf load /org/nemo/ < nemo.dconf

echo "Setup complete."
