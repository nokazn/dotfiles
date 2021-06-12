# dotfiles

[![CI](https://github.com/nokazn/dotfiles/actions/workflows/static-check.yml/badge.svg?branch=main)](https://github.com/nokazn/dotfiles/actions/workflows/static-check.yml)

## installation

```bash
$ git clone git@github.com:nokazn/dotfiles ~/dotfiles
$ cd ~/dotfiles
$ make init
```

`make init` makes symbolic links to files that starting with a dot and followed 2 or more chars in `~/dotfiles/` directory.  
If a existing file conflicts with the symbolic link, this is backed up in `~/dotfiles_backup/` directory.
