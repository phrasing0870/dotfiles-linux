# Linux Dotfiles

Personal Linux Mint configuration and fresh-install setup files.

## Includes

- Bash configuration
- Bash aliases
- Git configuration
- Curated APT package list
- Flatpak application list
- VSCodium settings and extensions
- Brave preferences
- Cinnamon settings
- Nemo settings
- LocalSend firewall configuration
- yt-dlp setup
- Package list update script
- Fresh-install bootstrap script

## Install

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

## What the Installer Does

- Verifies the system is Linux Mint or Ubuntu-based
- Updates APT
- Installs curated APT packages
- Configures Flathub
- Installs Flatpak applications
- Restores selected Brave preferences
- Installs VSCodium extensions
- Installs the latest yt-dlp
- Backs up existing Bash and Git configuration files
- Links dotfiles with GNU Stow
- Restores Cinnamon settings
- Restores Nemo settings
- Configures LocalSend firewall rules

## Manual Steps After Install

Authenticate GitHub CLI:

```bash
gh auth login
gh auth setup-git
```

Then:

- Log into applications
- Open Brave once before restoring Brave settings if its profile does not exist yet
- Reboot or log out and back in if Cinnamon settings need a refresh

## Structure

```text
dotfiles-linux/
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
│   └── .var/
│       └── app/
│           └── com.vscodium.codium/
│               └── config/
│                   └── VSCodium/
│                       └── User/
│                           └── settings.json
├── cinnamon.dconf
├── nemo.dconf
├── install.sh
├── README.md
└── .gitignore
```

## Package Lists

### APT

`packages/apt.txt` contains a curated list of packages to install on a fresh Linux Mint system.

The list is maintained manually instead of exporting every installed package because Mint and Ubuntu install many system packages and dependencies automatically.

### Flatpak

`packages/flatpak.txt` contains the Flatpak application IDs to restore.

### VSCodium Extensions

`packages/vscodium-extensions.txt` contains the extensions currently installed in VSCodium.

Refresh the automatically managed package lists with:

```bash
./scripts/update-lists
```

The script updates:

```text
packages/flatpak.txt
packages/vscodium-extensions.txt
```

It also shows any changes detected by Git.

The APT package list remains manually curated.

## Bash Setup

Bash configuration is stored in:

```text
bash/.bashrc
bash/.bash_aliases
```

GNU Stow links these files into the home directory:

```text
~/.bashrc
~/.bash_aliases
```

The Bash configuration includes:

- `~/.local/bin` in PATH
- 10,000-entry command history
- Git shortcuts
- yt-dlp shortcuts
- Navigation shortcuts
- Package update and cleanup aliases

## Git Setup

Git configuration is stored in:

```text
git/.gitconfig
```

It includes:

- Git user configuration
- `main` as the default branch
- Nano as the default editor
- GitHub CLI credential helper

GitHub authentication credentials are not stored in this repository.

After a fresh setup, authenticate with:

```bash
gh auth login
gh auth setup-git
```

## VSCodium

VSCodium is installed through Flatpak.

User settings are stored in:

```text
vscodium/.var/app/com.vscodium.codium/config/VSCodium/User/settings.json
```

GNU Stow links the configuration into the VSCodium Flatpak config directory.

Extensions are stored in:

```text
packages/vscodium-extensions.txt
```

The installer restores them automatically.

To refresh the saved extension list:

```bash
./scripts/update-lists
```

## Brave

Selected Brave preferences are stored in:

```text
brave/preferences.json
```

The repository does not store the full Brave profile.

Sensitive or machine-specific data such as the following is intentionally excluded:

- Cookies
- Browsing history
- Saved sessions
- Account state
- Secure Preferences
- Cache
- Extension state
- Password data

During setup, the installer merges the curated preferences into:

```text
~/.config/BraveSoftware/Brave-Browser/Default/Preferences
```

Brave should be closed while preferences are being restored.

If the profile does not exist yet, open Brave once, close it, and rerun the installer.

## yt-dlp

The installer downloads the latest official yt-dlp binary to:

```text
~/.local/bin/yt-dlp
```

FFmpeg is installed through APT.

Available aliases include:

```text
dlvid
dlvid720
dlvid4k
dlmp3
dlplaylist
dlplaylist720
```

## Desktop Settings

Cinnamon settings are stored in:

```text
cinnamon.dconf
```

Nemo settings are stored in:

```text
nemo.dconf
```

The installer restores these settings using `dconf`.

This includes personal Cinnamon configuration such as custom keyboard shortcuts.

To update the saved settings:

```bash
dconf dump /org/cinnamon/ > cinnamon.dconf
dconf dump /org/nemo/ > nemo.dconf
```

Review the files before committing them to make sure they do not contain unwanted machine-specific information.

## LocalSend

LocalSend is installed through Flatpak.

The installer configures UFW to allow LocalSend discovery and transfers on:

```text
53317/tcp
53317/udp
```

## Dry Run

Before running the installer or after making major changes, use:

```bash
./install.sh --dry-run
```

Dry-run mode shows what the installer would do without:

- Installing APT packages
- Installing Flatpaks
- Restoring Brave preferences
- Installing VSCodium extensions
- Downloading yt-dlp
- Moving existing dotfiles
- Running GNU Stow
- Restoring Cinnamon settings
- Restoring Nemo settings
- Changing firewall rules

## Updating Package Lists

Refresh the Flatpak and VSCodium extension lists:

```bash
./scripts/update-lists
```

If nothing has changed:

```text
==> Changes
No package list changes.
```

If applications or extensions have changed, the script displays the Git diff.

The APT package list remains manually curated.

## Updating the Repository

Check for changes:

```bash
git status
```

Review changes:

```bash
git diff
```

Review staged changes:

```bash
git --no-pager diff --cached
```

Stage changes:

```bash
git add .
```

Commit:

```bash
git commit -m "Update dotfiles"
```

Push:

```bash
git push
```
