# dotfiles

[![CI](https://github.com/nokazn/dotfiles/actions/workflows/static-check.yml/badge.svg?branch=main)](https://github.com/nokazn/dotfiles/actions/workflows/static-check.yml)

[![screenshot](./docs/img/arch-linux.jpg)](./docs/img/arch-linux.jpg)

## Installation

If `git`, `make`, `gcc`, `curl`, `wget`, `unzip` and `xz-utils` are not available in your environment, you need to install these packages.

```bash
# Ubuntu/Debian
$ sudo apt update -y && sudo apt install -y git make gcc curl wget unzip xz-utils

# Arch Linux
$ sudo pacman -Syu && sudo pacman -S git make gcc curl wget unzip openssh
```

`make init` command executes targets below.

- `add-tools`
  - `add-nix` - add Nix
  - `add-home-manager` - add home-manager
  - `add-dein-vim` - add dein.vim
- `install`
  - `install-asdf-langs` - install asdf-vm (Node.js, yarn, Terraform & etc.)
  - `install-rust` - install Rust
  - `install-nim` - install Nim

```bash
$ git clone git@github.com:nokazn/dotfiles ~/dotfiles
$ cd ~/dotfiles
# Install all development tools & language runtime
$ make init
```

## Configuration

### Change default shell

```bash
# `chshs` is an alias for `chsh -s`
$ chshs zsh
```

### Set up wsl-hello-sudo

```bash
# Add wsl-hello-sudo
$ make add-wsl-hello-sudo
```

After installing wsl-hello-sudo, you need to modify `/etc/pam.d/sudo`.

```diff
+ auth  sufficient pam_wsl_hello.so
```

See [wsl-hello-sudo document for configuration](https://github.com/nullpo-head/WSL-Hello-sudo#configuration) for details.
