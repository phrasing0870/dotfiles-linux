# Linux Dotfiles

Personal Linux Mint configuration and setup files.

## Includes

- Bash configuration
- Bash aliases
- Git configuration
- APT package list
- Flatpak package list
- Setup scripts
- Cinnamon settings
- Nemo settings
- LocalSend firewall configuration
- yt-dlp setup

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

- Updates APT
- Installs curated APT packages
- Configures Flathub
- Installs Flatpak applications
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
- Reboot or log out and back in if Cinnamon settings need a refresh

## Structure

```text
dotfiles-linux/
├── bash/
│   ├── .bash_aliases
│   └── .bashrc
├── git/
│   └── .gitconfig
├── packages/
│   ├── apt.txt
│   └── flatpak.txt
├── scripts/
│   └── update-package-lists
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

Refresh the Flatpak list with:

```bash
./scripts/update-package-lists
```

The APT package list is not automatically regenerated.

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

- Installing packages
- Installing Flatpaks
- Downloading yt-dlp
- Moving existing dotfiles
- Running GNU Stow
- Restoring Cinnamon or Nemo settings
- Changing firewall rules

## Updating Package Lists

Refresh the Flatpak application list:

```bash
./scripts/update-package-lists
```

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
