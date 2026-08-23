# Linux Dotfiles

Personal Linux Mint configuration and fresh-install setup files.

## Includes

- Alacritty configuration
- Bash configuration and aliases
- Git configuration
- Curated APT package list
- Flatpak application list
- VSCodium settings and extensions
- Selected Brave preferences
- Cinnamon and Nemo settings
- LocalSend firewall configuration
- yt-dlp setup
- Package list update script
- Fresh-install bootstrap script

## Install

On a fresh Linux Mint installation, install Git first:

```bash
sudo apt update
sudo apt install -y git
```

Clone the repository:

```bash
git clone https://github.com/phrasing0870/dotfiles-linux.git ~/Documents/dotfiles-linux
cd ~/Documents/dotfiles-linux
```

Preview what the installer will do:

```bash
./install.sh --dry-run
```

Run the installer:

```bash
./install.sh
```

The installer is intended for Linux Mint and other Ubuntu-based systems. It is safe to rerun. Existing regular dotfiles that would conflict with Stow are renamed with a timestamped `.backup-*` suffix.

## What the Installer Does

- Verifies the system and required repository files
- Updates APT and installs the curated APT packages
- Installs Alacritty and JetBrains Mono
- Configures Flathub and installs Flatpak applications
- Restores selected Brave preferences when a Brave profile exists
- Installs VSCodium extensions
- Installs the latest official yt-dlp binary
- Backs up conflicting Bash, Git, Alacritty, and VSCodium files
- Links Bash, Git, Alacritty, and VSCodium configuration with GNU Stow
- Restores Cinnamon and Nemo settings
- Configures LocalSend firewall rules

## Manual Steps After Install

Authenticate GitHub CLI:

```bash
gh auth login
gh auth setup-git
```

Then:

- Log into applications
- If Brave preferences were skipped, open Brave once, close it, and rerun the installer
- Log out or reboot if Cinnamon settings need a refresh

Brave must be closed while its preferences are restored.

## Structure

```text
dotfiles-linux/
├── alacritty/
│   └── .config/alacritty/alacritty.toml
├── bash/
│   ├── .bash_aliases
│   └── .bashrc
├── brave/
│   └── preferences.json
├── git/
│   └── .gitconfig
├── packages/
│   ├── apt.txt
│   ├── flatpak.txt
│   └── vscodium-extensions.txt
├── scripts/
│   └── update-lists
├── vscodium/
│   └── .var/app/com.vscodium.codium/config/VSCodium/User/settings.json
├── cinnamon.dconf
├── nemo.dconf
├── install.sh
├── README.md
└── .gitignore
```

## Stow Packages

The installer links these packages into your home directory:

| Package | Managed path |
| --- | --- |
| `bash` | `~/.bashrc`, `~/.bash_aliases` |
| `git` | `~/.gitconfig` |
| `alacritty` | `~/.config/alacritty/alacritty.toml` |
| `vscodium` | `~/.var/app/com.vscodium.codium/config/VSCodium/User/settings.json` |

## Package Lists

`packages/apt.txt` is manually curated. This avoids capturing the large set of packages installed automatically by Mint and Ubuntu.

`packages/flatpak.txt` contains Flatpak application IDs. `packages/vscodium-extensions.txt` contains VSCodium extension IDs.

Refresh the automatically managed lists with:

```bash
./scripts/update-lists
```

The script updates the Flatpak and VSCodium lists and shows their Git diff. It does not change the APT list.

## Alacritty

Alacritty configuration is stored at:

```text
alacritty/.config/alacritty/alacritty.toml
```

The installer installs Alacritty and `fonts-jetbrains-mono`, backs up a conflicting regular configuration file, and links the saved configuration with Stow.

The configuration uses the `JetBrains Mono` family supplied by the `fonts-jetbrains-mono` APT package.

## Brave

The repository stores selected Brave preferences rather than the full profile. It intentionally excludes cookies, history, sessions, account state, extension state, passwords, cache, and `Secure Preferences`.

During setup, the installer merges `brave/preferences.json` into:

```text
~/.config/BraveSoftware/Brave-Browser/Default/Preferences
```

If the profile does not exist, the installer skips this step with instructions. Open Brave once, close it, and rerun the installer.

## yt-dlp

The installer downloads the latest official yt-dlp binary to:

```text
~/.local/bin/yt-dlp
```

FFmpeg is installed through APT. Download aliases are defined in `bash/.bash_aliases`.

## Desktop Settings

Cinnamon and Nemo settings are restored from `cinnamon.dconf` and `nemo.dconf`.

Update the saved settings with:

```bash
dconf dump /org/cinnamon/ > cinnamon.dconf
dconf dump /org/nemo/ > nemo.dconf
```

Review both files before committing them for unwanted machine-specific values.

## LocalSend

LocalSend is installed through Flatpak. The installer allows discovery and transfers through UFW on `53317/tcp` and `53317/udp`, and enables UFW if it is inactive.

## Validation

Check the installer and its Stow packages before committing:

```bash
bash -n install.sh
shellcheck install.sh scripts/update-lists
./install.sh --dry-run
stow_test_dir="$(mktemp -d)"
stow -n -v -R --dir="$PWD" --target="$stow_test_dir" bash git alacritty vscodium
rmdir "$stow_test_dir"
```

Review changes:

```bash
git status
git diff
```

Then stage, commit, and push from VS Code or the terminal.