# dotfiles

[![CI](https://github.com/nokazn/dotfiles/actions/workflows/static-check.yml/badge.svg?branch=main)](https://github.com/nokazn/dotfiles/actions/workflows/static-check.yml)

[![screenshot](./docs/img/arch-linux.jpg)](./docs/img/arch-linux.jpg)

## Installation

### For Linux (user environment)

If `git`, `make`, `gcc`, `curl`, `wget`, `unzip` and `xz-utils` are not available in your environment, you need to install these packages.

```sh
# Ubuntu/Debian
$ sudo apt update -y && sudo apt install -y git make gcc curl wget unzip xz-utils

# Arch Linux
$ sudo pacman -Syu && sudo pacman -S git make gcc curl wget unzip openssh
```

`make init/linux-user` command executes targets below.

- `add-tools/linux-user`
  - `add-tools/nix` - add Nix
  - `apply/linux-user` - apply `home-manager switch`
- `install`
  - `install/asdf-langs` - install asdf-vm and some languages by it

```sh
$ git clone git@github.com:nokazn/dotfiles ~/dotfiles
$ cd ~/dotfiles
# Install all development tools & language runtime
$ make init/linux-user
```

### For darwin

`make init/darwin` command executes targets below.

- `add-tools/darwin`
  - `add-tools/nix` - add Nix
  - `apply/darwin` - apply `nix-darwin switch`
- `install`
  - `install/asdf-langs` - install asdf-vm and some languages by it

```sh
$ git clone git@github.com:nokazn/dotfiles ~/dotfiles
$ cd ~/dotfiles
# Install all development tools & language runtime
$ make init/darwin
```

## Configuration

### Change default shell

```bash
# `chshs` is an alias for `chsh -s`
$ chshs zsh
```

### Set up wsl-hello-sudo (optional)

```bash
# Add wsl-hello-sudo
$ make add/wsl-hello-sudo
```

After installing wsl-hello-sudo, you need to modify `/etc/pam.d/sudo`.

```diff
+ auth  sufficient pam_wsl_hello.so
```

See [wsl-hello-sudo document for configuration](https://github.com/nullpo-head/WSL-Hello-sudo#configuration) for details.
