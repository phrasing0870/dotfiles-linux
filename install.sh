#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# --- Verify distro ---

if [[ ! -f /etc/os-release ]]; then
    echo "Error: Cannot identify Linux distribution."
    exit 1
fi

source /etc/os-release

if [[ "${ID:-}" != "linuxmint" && "${ID_LIKE:-}" != *"ubuntu"* ]]; then
    echo "Error: This installer is intended for Linux Mint/Ubuntu-based systems."
    exit 1
fi


# --- APT ---

echo "==> Updating APT"
sudo apt update

echo "==> Installing APT packages"
sudo xargs -r -a packages/apt.txt apt install -y


# --- Flatpak ---

echo "==> Configuring Flathub"

flatpak remote-add --if-not-exists \
    flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

echo "==> Installing Flatpaks"

while IFS= read -r app; do
    [[ -z "$app" ]] && continue
    flatpak install -y flathub "$app"
done < packages/flatpak.txt


# --- yt-dlp ---

echo "==> Installing yt-dlp"

mkdir -p "$HOME/.local/bin"

curl -fL \
    https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    -o "$HOME/.local/bin/yt-dlp"

chmod +x "$HOME/.local/bin/yt-dlp"


# --- Existing dotfiles ---

echo "==> Preparing dotfiles"

BACKUP_SUFFIX="$(date +%Y%m%d-%H%M%S)"

for file in .bashrc .bash_aliases .gitconfig; do
    target="$HOME/$file"

    if [[ -f "$target" && ! -L "$target" ]]; then
        echo "Backing up $target"
        mv "$target" "$target.backup-$BACKUP_SUFFIX"
    fi
done


# --- GNU Stow ---

echo "==> Linking dotfiles"

for package in bash git; do
    stow -R -t "$HOME" "$package"
done


# --- Cinnamon / Nemo ---

if [[ -f cinnamon.dconf ]]; then
    echo "==> Restoring Cinnamon settings"
    dconf load /org/cinnamon/ < cinnamon.dconf
fi

if [[ -f nemo.dconf ]]; then
    echo "==> Restoring Nemo settings"
    dconf load /org/nemo/ < nemo.dconf
fi


# --- Firewall ---

echo "==> Configuring firewall"

if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow 53317/tcp comment 'LocalSend'
    sudo ufw allow 53317/udp comment 'LocalSend'

    if ! sudo ufw status | grep -q '^Status: active'; then
        sudo ufw --force enable
    fi
else
    echo "Warning: ufw is not installed, skipping firewall setup."
fi


echo
echo "Setup complete."
echo
echo "Remaining manual steps:"
echo "  1. Run: gh auth login"
echo "  2. Run: gh auth setup-git"
echo "  3. Log into your applications"
echo "  4. Reboot or log out/in if Cinnamon settings need a refresh"
