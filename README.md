# dotfiles

[![CI](https://github.com/nokazn/dotfiles/actions/workflows/static-check.yml/badge.svg?branch=main)](https://github.com/nokazn/dotfiles/actions/workflows/static-check.yml)

## installation

If `make`, `curl`, `wget` and `xz-utils` are not available, you need to install these packages.

```bash
# Ubuntu/Debian
$ suo apt install -y make curl wget xz-utils
```

`make init` makes symbolic links to files that starting with a dot and followed 2 or more chars in `~/dotfiles/` directory.  
If a existing file conflicts with the symbolic link, this is backed up in `~/dotfiles_backup/` directory.


```bash
$ git clone git@github.com:nokazn/dotfiles ~/dotfiles
$ cd ~/dotfiles
$ make init
```
