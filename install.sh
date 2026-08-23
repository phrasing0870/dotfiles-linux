#!/usr/bin/env bash

set -euo pipefail

DRY_RUN=false

case "${1:-}" in
    "") ;;
    --dry-run) DRY_RUN=true ;;
    *)
        echo "Usage: $0 [--dry-run]" >&2
        exit 2
        ;;
esac

run() {
    if $DRY_RUN; then
        printf 'DRY-RUN:'
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# --- Required files ---

required_files=(
    "alacritty/.config/alacritty/alacritty.toml"
    "bash/.bashrc"
    "bash/.bash_aliases"
    "git/.gitconfig"
    "vscodium/.var/app/com.vscodium.codium/config/VSCodium/User/settings.json"
    "packages/apt.txt"
    "packages/flatpak.txt"
    "packages/vscodium-extensions.txt"
    "brave/preferences.json"
)

for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: Required file is missing: $file" >&2
        exit 1
    fi
done

# --- Verify distro ---

if [[ ! -f /etc/os-release ]]; then
    echo "Error: Cannot identify Linux distribution." >&2
    exit 1
fi
# shellcheck disable=SC1091
source /etc/os-release

if [[ "${ID:-}" != "linuxmint" && "${ID_LIKE:-}" != *"ubuntu"* ]]; then
    echo "Error: This installer is intended for Linux Mint/Ubuntu-based systems." >&2
    exit 1
fi

# --- APT ---

echo "==> Updating APT"
run sudo apt update

echo "==> Installing APT packages"

if $DRY_RUN; then
    echo "DRY-RUN: would install packages from packages/apt.txt"
else
    sudo xargs -r -a packages/apt.txt apt install -y
fi

# --- Flatpak ---

echo "==> Configuring Flathub"

run flatpak remote-add \
    --if-not-exists \
    flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

echo "==> Installing Flatpaks"

while IFS= read -r app; do
    [[ -z "$app" ]] && continue
    run flatpak install -y flathub "$app"
done < packages/flatpak.txt

# --- Brave preferences ---

BRAVE_PREFS="$HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences"
BRAVE_DOTFILES_PREFS="$DOTFILES_DIR/brave/preferences.json"

echo "==> Restoring Brave preferences"

if $DRY_RUN; then
    echo "DRY-RUN: would merge $BRAVE_DOTFILES_PREFS into $BRAVE_PREFS"
elif [[ -f "$BRAVE_PREFS" ]]; then
    tmp="$(mktemp)"
    trap 'rm -f "$tmp"' EXIT

    jq -s '.[0] * .[1]' \
        "$BRAVE_PREFS" \
        "$BRAVE_DOTFILES_PREFS" \
        > "$tmp"

    mv "$tmp" "$BRAVE_PREFS"
    trap - EXIT
else
    echo "Warning: Brave preferences not found."
    echo "         Open Brave once, close it, then rerun the installer."
fi

# --- VSCodium extensions ---

echo "==> Installing VSCodium extensions"

while IFS= read -r extension; do
    [[ -z "$extension" ]] && continue

    if $DRY_RUN; then
        run flatpak run com.vscodium.codium \
            --install-extension "$extension"
    else
        flatpak run com.vscodium.codium \
            --install-extension "$extension" ||
            echo "Warning: Failed to install VSCodium extension: $extension"
    fi
done < packages/vscodium-extensions.txt

# --- yt-dlp ---

echo "==> Installing yt-dlp"

run mkdir -p "$HOME/.local/bin"

run curl -fL \
    https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    -o "$HOME/.local/bin/yt-dlp"

run chmod +x "$HOME/.local/bin/yt-dlp"

# --- Existing dotfiles ---

echo "==> Preparing dotfiles"

BACKUP_SUFFIX="$(date +%Y%m%d-%H%M%S)"

backup_regular_file() {
    local target="$1"

    if [[ -e "$target" && ! -L "$target" ]]; then
        run mv "$target" "$target.backup-$BACKUP_SUFFIX"
    fi
}

backup_regular_file "$HOME/.bashrc"
backup_regular_file "$HOME/.bash_aliases"
backup_regular_file "$HOME/.gitconfig"
backup_regular_file "$HOME/.config/alacritty/alacritty.toml"
backup_regular_file "$HOME/.var/app/com.vscodium.codium/config/VSCodium/User/settings.json"

# --- GNU Stow ---

echo "==> Linking dotfiles"

for package in bash git alacritty vscodium; do
    run stow -R --dir="$DOTFILES_DIR" --target="$HOME" "$package"
done

# --- Cinnamon / Nemo ---

if [[ -f cinnamon.dconf ]]; then
    echo "==> Restoring Cinnamon settings"

    if $DRY_RUN; then
        echo "DRY-RUN: would restore cinnamon.dconf"
    else
        dconf load /org/cinnamon/ < cinnamon.dconf
    fi
fi

if [[ -f nemo.dconf ]]; then
    echo "==> Restoring Nemo settings"

    if $DRY_RUN; then
        echo "DRY-RUN: would restore nemo.dconf"
    else
        dconf load /org/nemo/ < nemo.dconf
    fi
fi

# --- Firewall ---

echo "==> Configuring firewall"

if command -v ufw >/dev/null 2>&1; then
    if $DRY_RUN; then
        echo "DRY-RUN: sudo ufw allow 53317/tcp comment LocalSend"
        echo "DRY-RUN: sudo ufw allow 53317/udp comment LocalSend"
        echo "DRY-RUN: would ensure UFW is enabled"
    else
        sudo ufw allow 53317/tcp comment LocalSend
        sudo ufw allow 53317/udp comment LocalSend

        if ! sudo ufw status | grep -q '^Status: active'; then
            sudo ufw --force enable
        fi
    fi
else
    echo "Warning: ufw is not installed, skipping firewall setup."
fi

echo

if $DRY_RUN; then
    echo "Dry run complete. No changes were made."
else
    echo "Setup complete."
    echo
    echo "Remaining manual steps:"
    echo "  1. Run: gh auth login"
    echo "  2. Run: gh auth setup-git"
    echo "  3. Log into your applications"
    echo "  4. Reboot or log out/in if Cinnamon settings need a refresh"
fi