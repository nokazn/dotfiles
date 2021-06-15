# dotfiles

[![CI](https://github.com/nokazn/dotfiles/actions/workflows/static-check.yml/badge.svg?branch=main)](https://github.com/nokazn/dotfiles/actions/workflows/static-check.yml)

## Installation

If `git`, `make`, `curl`, `wget` and `xz-utils` are not available in your environment, you need to install these packages.

```bash
# Ubuntu/Debian
$ suo apt install -y git make curl wget xz-utils
```

`make init` makes symbolic links to files that starting with a dot and followed 2 or more chars in `~/dotfiles/` directory.  
If a existing file conflicts with the symbolic link, this is backed up in `~/dotfiles_backup/` directory.


```bash
$ git clone git@github.com:nokazn/dotfiles ~/dotfiles
$ cd ~/dotfiles
$ make init
```

## Configuration

### Set up wsl-hello-sudo

After installing wsl-hello-sudo, you need to modify `/etc/pam.d/sudo`.

```diff
+ auth  sufficient pam_wsl_hello.so
```

See [wsl-hello-sudo document for configuration](https://github.com/nullpo-head/WSL-Hello-sudo#configuration) for details.

### Change default shell

```bash
$ chsh -s "$(which zsh)"
```
