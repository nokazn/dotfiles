if (!(Get-Command "scoop" -ErrorAction SilentlyContinue)) {
  Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')

  if (!(Get-Command "scoop" -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Failed to install Scoop."
    exit 1;
  }
  Write-Host "✅ Scoop is successfully installed."
}

scoop bucket add extras
scoop bucket add games
scoop bucket add nirsoft
scoop bucket add nonportable

# scoop install `
#   googlechrome `
#   firefox `
#   opera `
#   vivaldi `
#   vscode `
#   git `
#   postman `
#   jasper
#   gimp `
#   vlc `
#   thunderbird `
#   slack `
#   zoom `
#   typora `
#   notion `
#   boostnote `
#   keepassxc `
#   everything `
#   fastcopy `
#   crystaldiskmark `
#   crystaldiskinfo `
#   screentogif
