# Linux Dotfiles

Personal Linux Mint configuration and fresh-install setup files.

## Includes

- Alacritty configuration
- Bash configuration and aliases
- Git configuration
- Curated APT package list
- Flatpak application list
- VSCodium settings and extensions
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

The installer is intended for Linux Mint and other Ubuntu-based systems. A normal run restores everything. Existing files and settings are backed up before they are changed.

### Installer Options

Options can be combined:

```text
--dry-run        Preview actions without making changes
--skip-desktop   Do not restore Cinnamon or Nemo settings
--skip-firewall  Do not add LocalSend firewall rules
-h, --help       Show installer help
```

Example:

```bash
./install.sh --dry-run --skip-firewall
```

## Backups

Each run that changes existing files or settings stores them in one timestamped directory:

```text
~/.local/state/dotfiles-linux/backups/YYYYMMDD-HHMMSS/
```

The backup may contain:

```text
desktop/cinnamon.dconf
desktop/nemo.dconf
home/.bashrc
home/.bash_aliases
home/.gitconfig
home/.config/alacritty/alacritty.toml
home/.var/app/com.vscodium.codium/config/VSCodium/User/settings.json
```

Only files and settings that existed before the run are included. Existing Stow-managed symlinks are left alone.

### Restoring a Backup

Choose the timestamped directory you want to restore:

```bash
backup_dir="$HOME/.local/state/dotfiles-linux/backups/YYYYMMDD-HHMMSS"
```

Restore saved desktop settings when those files exist:

```bash
dconf load /org/cinnamon/ < "$backup_dir/desktop/cinnamon.dconf"
dconf load /org/nemo/ < "$backup_dir/desktop/nemo.dconf"
```

Dotfile backups under `home/` are the original files moved out of the way before Stow linked the repository. Restore only the files you need after removing their Stow links.

## What the Installer Does

- Verifies the system and required repository files
- Updates APT and installs the curated APT packages
- Installs Alacritty and JetBrains Mono
- Configures Flathub and installs Flatpak applications
- Installs VSCodium extensions
- Installs the latest official yt-dlp binary
- Backs up conflicting dotfiles in one timestamped directory
- Links Bash, Git, Alacritty, and VSCodium configuration with GNU Stow
- Backs up and restores Cinnamon and Nemo settings
- Adds LocalSend UFW rules without enabling UFW

## Manual Steps After Install

Authenticate GitHub CLI:

```bash
gh auth login
gh auth setup-git
```

Then:

- Log into applications
- Review `sudo ufw status` and run `sudo ufw enable` if wanted
- Log out or reboot if Cinnamon settings need a refresh

## Structure

```text
dotfiles-linux/
├── alacritty/
│   └── .config/alacritty/alacritty.toml
├── bash/
│   ├── .bash_aliases
│   └── .bashrc
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

## yt-dlp

The installer downloads the latest official yt-dlp binary to:

```text
~/.local/bin/yt-dlp
```

FFmpeg is installed through APT. Download aliases are defined in `bash/.bash_aliases`.

## Desktop Settings

Cinnamon and Nemo settings are backed up and then restored from `cinnamon.dconf` and `nemo.dconf`.

Update the saved settings with:

```bash
dconf dump /org/cinnamon/ > cinnamon.dconf
dconf dump /org/nemo/ > nemo.dconf
```

Review both files before committing them for unwanted machine-specific values.

## LocalSend

LocalSend is installed through Flatpak. Unless `--skip-firewall` is used, the installer adds UFW rules for `53317/tcp` and `53317/udp`.

The installer does not enable UFW. Review its state after setup:

```bash
sudo ufw status
sudo ufw enable
```

## Validation

Check the installer and its Stow packages before committing:

```bash
bash -n install.sh
shellcheck install.sh scripts/update-lists
./install.sh --dry-run
./install.sh --dry-run --skip-desktop --skip-firewall
stow_test_dir="$(mktemp -d)"
stow -n -v -R --dir="$PWD" --target="$stow_test_dir" bash git alacritty vscodium
rmdir "$stow_test_dir"
git diff --check
```

Review changes:

```bash
git status
git diff
```

Then stage, commit, and push from VS Code or the terminal.
