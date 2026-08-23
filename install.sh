#!/usr/bin/env bash

set -euo pipefail

DRY_RUN=false
SKIP_BRAVE=false
SKIP_DESKTOP=false
SKIP_FIREWALL=false

usage() {
    cat <<EOF
Usage: $0 [options]

Options:
  --dry-run        Preview actions without making changes
  --skip-brave     Do not restore Brave preferences
  --skip-desktop   Do not restore Cinnamon or Nemo settings
  --skip-firewall  Do not add LocalSend firewall rules
  -h, --help       Show this help
EOF
}

while (( $# > 0 )); do
    case "$1" in
        --dry-run) DRY_RUN=true ;;
        --skip-brave) SKIP_BRAVE=true ;;
        --skip-desktop) SKIP_DESKTOP=true ;;
        --skip-firewall) SKIP_FIREWALL=true ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

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
BACKUP_SUFFIX="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/.local/state/dotfiles-linux/backups/$BACKUP_SUFFIX"
BACKUPS_PLANNED=false

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

# --- Backup helpers ---

backup_move() {
    local source="$1"
    local relative_destination="$2"
    local destination="$BACKUP_DIR/$relative_destination"

    if [[ (! -e "$source" && ! -L "$source") || -L "$source" ]]; then
        return
    fi

    BACKUPS_PLANNED=true
    run mkdir -p "$(dirname "$destination")"
    run mv -- "$source" "$destination"
}

backup_copy() {
    local source="$1"
    local relative_destination="$2"
    local destination="$BACKUP_DIR/$relative_destination"

    [[ -e "$source" ]] || return

    BACKUPS_PLANNED=true
    run mkdir -p "$(dirname "$destination")"
    run cp -a -- "$source" "$destination"
}

backup_dconf() {
    local dconf_path="$1"
    local relative_destination="$2"
    local destination="$BACKUP_DIR/$relative_destination"

    BACKUPS_PLANNED=true

    if $DRY_RUN; then
        echo "DRY-RUN: would back up $dconf_path to $destination"
    else
        mkdir -p "$(dirname "$destination")"
        dconf dump "$dconf_path" > "$destination"
    fi
}

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

if $SKIP_BRAVE; then
    echo "==> Skipping Brave preferences"
else
    echo "==> Restoring Brave preferences"

    if [[ -f "$BRAVE_PREFS" ]]; then
        backup_copy "$BRAVE_PREFS" "brave/Preferences"

        if $DRY_RUN; then
            echo "DRY-RUN: would merge $BRAVE_DOTFILES_PREFS into $BRAVE_PREFS"
        else
            tmp="$(mktemp)"
            trap 'rm -f "$tmp"' EXIT

            jq -s '.[0] * .[1]' \
                "$BRAVE_PREFS" \
                "$BRAVE_DOTFILES_PREFS" \
                > "$tmp"

            mv "$tmp" "$BRAVE_PREFS"
            trap - EXIT
        fi
    else
        echo "Warning: Brave preferences not found."
        echo "         Open Brave once, close it, then rerun the installer."
    fi
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

backup_move "$HOME/.bashrc" "home/.bashrc"
backup_move "$HOME/.bash_aliases" "home/.bash_aliases"
backup_move "$HOME/.gitconfig" "home/.gitconfig"
backup_move "$HOME/.config/alacritty/alacritty.toml" \
    "home/.config/alacritty/alacritty.toml"
backup_move "$HOME/.var/app/com.vscodium.codium/config/VSCodium/User/settings.json" \
    "home/.var/app/com.vscodium.codium/config/VSCodium/User/settings.json"

# --- GNU Stow ---

echo "==> Linking dotfiles"

for package in bash git alacritty vscodium; do
    run stow -R --dir="$DOTFILES_DIR" --target="$HOME" "$package"
done

# --- Cinnamon / Nemo ---

if $SKIP_DESKTOP; then
    echo "==> Skipping Cinnamon and Nemo settings"
else
    if [[ -f cinnamon.dconf ]]; then
        echo "==> Restoring Cinnamon settings"
        backup_dconf /org/cinnamon/ "desktop/cinnamon.dconf"

        if ! $DRY_RUN; then
            dconf load /org/cinnamon/ < cinnamon.dconf
        fi
    fi

    if [[ -f nemo.dconf ]]; then
        echo "==> Restoring Nemo settings"
        backup_dconf /org/nemo/ "desktop/nemo.dconf"

        if ! $DRY_RUN; then
            dconf load /org/nemo/ < nemo.dconf
        fi
    fi
fi

# --- Firewall ---

if $SKIP_FIREWALL; then
    echo "==> Skipping firewall configuration"
else
    echo "==> Configuring firewall"

    if command -v ufw >/dev/null 2>&1; then
        run sudo ufw allow 53317/tcp comment LocalSend
        run sudo ufw allow 53317/udp comment LocalSend

        if $DRY_RUN; then
            echo "DRY-RUN: would check whether UFW is active"
        elif ! sudo ufw status | grep -q '^Status: active'; then
            echo "Warning: UFW is inactive. Rules were added, but UFW was not enabled."
            echo "         Enable it manually with: sudo ufw enable"
        fi
    else
        echo "Warning: ufw is not installed, skipping firewall setup."
    fi
fi

echo

if $DRY_RUN; then
    echo "Dry run complete. No changes were made."
else
    echo "Setup complete."
fi

if $BACKUPS_PLANNED; then
    if $DRY_RUN; then
        echo "Planned backup location: $BACKUP_DIR"
    else
        echo "Backups: $BACKUP_DIR"
    fi
fi

if ! $DRY_RUN; then
    echo
    echo "Remaining manual steps:"
    echo "  1. Run: gh auth login"
    echo "  2. Run: gh auth setup-git"
    echo "  3. Log into your applications"
    echo "  4. Review UFW status and enable it manually if wanted"
    echo "  5. Reboot or log out/in if Cinnamon settings need a refresh"
fi
