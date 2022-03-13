# dotfiles

[![CI](https://github.com/nokazn/dotfiles/actions/workflows/static-check.yml/badge.svg?branch=main)](https://github.com/nokazn/dotfiles/actions/workflows/static-check.yml)

[![screenshot](./docs/img/arch-linux.jpg)](./docs/img/arch-linux.jpg)

## Installation

If `git`, `make`, `gcc`, `curl`, `wget`, `unzip` and `xz-utils` are not available in your environment, you need to install these packages.

```bash
# Ubuntu/Debian
$ sudo apt update -y && sudo apt install -y git make gcc curl wget unzip xz-utils

# Arch Linux
$ sudo pacman -Syyu && sudo pacman -S git make gcc curl wget unzip
```

`make deploy` command makes symbolic links to files that starting with a dot and followed 2 or more chars in `~/dotfiles/` directory.  
If a existing file conflicts with the symbolic link, this is backed up.

`make init` command executes targets below.

- `update-apt` - Update apt packages
- `add-tools`
  - `add-nix` - Add nix
  - `add-home-manager` - Add home-manager
  - `add-dein-vim` - Add dein-vim
  - `add-bash-it` - Add bash-it
  - `add-wsl-hello-sudo` - Add wsl-hello-sudo
- `install-anyenv` - Install anyenv
- `install-anyenv-langs` - Install languages by anyenv (Node.js, Go)
- `install-langs`
  - `install-deno` - Install Deno
  - `install-rust` - Install Rust
  - `install-elm` - Install Elm
  - `install-nim` - Install Nim

```bash
$ git clone git@github.com:nokazn/dotfiles ~/dotfiles
$ cd ~/dotfiles
# Install all languages & packages
$ make init
```

## Configuration

### Change default shell

```bash
#  `chshs` alias is defined in .bash_aliases
$ chshs zsh
```

### Set up wsl-hello-sudo

After installing wsl-hello-sudo, you need to modify `/etc/pam.d/sudo`.

```diff
+ auth  sufficient pam_wsl_hello.so
```

See [wsl-hello-sudo document for configuration](https://github.com/nullpo-head/WSL-Hello-sudo#configuration) for details.
