# dotfiles

[![CI](https://github.com/nokazn/dotfiles/actions/workflows/static-check.yml/badge.svg?branch=main)](https://github.com/nokazn/dotfiles/actions/workflows/static-check.yml)

[![screenshot](./docs/img/arch-linux.jpg)](./docs/img/arch-linux.jpg)

## Installation

```sh
# Generate SSH key (and then need to register public key to GitHub)
$ mkdir -p ~/.ssh/github.com && \
  ssh-keygen -t ed25519 -C nokazn@gmail.com -f ~/.ssh/github.com/id_rsa -N "" && \
  cat ~/.ssh/github.com/id_rsa.pub
$ curl https://raw.githubusercontent.com/nokazn/dotfiles/main/unix/.ssh/config > ~/.ssh/config
$ ssh -T github.com

$ sudo tee /etc/wsl.conf <<EOF
[user]
default = nokazn
EOF

$ sudo mkdir -p /etc/nix && sudo tee /etc/nix/nix.conf <<EOF
experimental-features = nix-command flakes
EOF
```

### For user environment

```sh
# Ubuntu/Debian
$ sudo apt update -y && sudo apt upgrade -y && sudo apt install -y git make wget curl

# Arch Linux
$ sudo pacman -Syu && sudo pacman -S base base-devel vi vim git make wget openssh
```

`make init/user` command executes targets below.

- `add-tools/nix` - add Nix
- `apply/user` - run `home-manager switch`
- `install/langs` - install some languages & tools by proto

```sh
$ git clone git@github.com:nokazn/dotfiles ~/dotfiles
$ cd ~/dotfiles

# Install all development tools & language runtime
$ make init/user
```

### For Windows

Files under `windows/` are managed by [chezmoi](https://github.com/twpayne/chezmoi) (`.chezmoiroot` points to `windows`).

```powershell
winget install twpayne.chezmoi
chezmoi init --apply <path to this repository>

# Install apps
.\.scripts\apply.ps1
```

`windows/wsl/wsl.conf` is copied to `/etc/wsl.conf` in WSL on `chezmoi apply` when it changes. Run `wsl --shutdown` afterwards to apply it.

Install apps for Linux

```sh
./scripts/flatpak.sh
```

### For darwin

`make init/darwin` command executes targets below.

- `add-tools/nix` - add Nix
- `apply/darwin` - run `nix-darwin switch`
- `install/langs` - install some languages & tools by proto

```sh
$ git clone git@github.com:nokazn/dotfiles ~/dotfiles
$ cd ~/dotfiles

# Install all development tools & language runtime & homebrew apps
$ make init/darwin
```

## Configuration

### Change default shell

```bash
# `chshs` is an alias for `chsh -s`
$ chshs zsh
```

### Set up sudo with Touch ID for macOS

```sh
sudo chmod +w /etc/pam.d/sudo
sudo vim /etc/pam.d/sudo
```

```diff
  # sudo: auth account password session
+ auth       sufficient     pam_tid.so
  auth       include        sudo_local
  auth       sufficient     pam_smartcard.so
  auth       required       pam_opendirectory.so
  account    required       pam_permit.so
  password   required       pam_deny.so
  session    required       pam_permit.so
```

```sh
sudo chmod -w /etc/pam.d/sudo
```

### Import a GPG key

```sh
# Login to keybase
$ keybase login
# If no service
$ keybase --standalone login

$ keybase config set -b pinentry.disabled 1

# Import a public key
$ keybase pgp export | gpg --import
# Import multiple public keys
$ keybase pgp export -q <ID> | gpg --import

# Import a secret key
$ keybase pgp export --secret | gpg --allow-secret-key-import --import
```
