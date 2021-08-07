if (!(Get-Command "choco" -ErrorAction SilentlyContinue)) {
  # https://chocolatey.org/install.ps1 が安全かどうか検証し、インストールする
  Set-ExecutionPolicy Bypass -Scope Process -Force;
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));

  if (!(Get-Command "choco" -ErrorAction SilentlyContinue)) {
    Write-Error "Chocolatey is not installed. You can get at https://chocolatey.org ."
    exit 1;
  }
}

choco install -y  `
  googlechrome `
  firefox `
  opera `
  vivaldi `
  vscode `
  git `
  vcxsrv `
  postman `
  pgadmin4 `
  jasper
  font-hackgen-nerd `
  # うまくセットアップできない `
  # docker-desktop `
  thunderbird `
  discord `
  slack `
  zoom `
  keybase `
  typora `
  todoist `
  notion `
  boostnote `
  keepassxc `
  everything `
  fastcopy `
  crystaldiskmark `
  crystaldiskinfo `
  adobereader `
  googledrive `
  keycastow `
  7zip `
  screentogif `
  spotify `
  lastfmscrobbler `
  gimp `
  vlc
