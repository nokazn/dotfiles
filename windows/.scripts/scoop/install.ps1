if (!(Get-Command "scoop" -ErrorAction SilentlyContinue)) {
  Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')

  if (!(Get-Command "scoop" -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Failed to install Scoop."
    exit 1;
  }
  Write-Host "✅ Scoop is successfully installed."
}

scoop install git

scoop bucket add extras
scoop bucket add games
scoop bucket add nirsoft
scoop bucket add nonportable

scoop install `
  main/fd `
  main/gsudo `
  extras/neovide `
  main/neovim `
  main/nu `
  main/ripgrep `
  extras/runcat `
  main/rustup `
  main/rustup-gnu main/mingw `
  main/starship `
  main/tokei `
  main/volta `
  main/yarn
