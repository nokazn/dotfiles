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
  7zip `
  adobereader `
  anaconda3 `
  blender `
  boostnote `
  cpu-z `
  crystaldiskinfo `
  crystaldiskmark `
  deepl `
  discord `
  everything `
  fastcopy `
  firefox `
  font-hackgen-nerd `
  gimp `
  git `
  googlechrome `
  googledrive `
  jasper `
  keepassxc `
  keybase `
  keycastow `
  lastfmscrobbler `
  microsoft-windows-terminal `
  miniconda3 `
  notion `
  opera `
  pgadmin4 `
  postman `
  screentogif `
  slack `
  steam `
  thunderbird `
  todoist `
  typora `
  unity `
  vcxsrv `
  vivaldi `
  vlc `
  vscode `
  zoom
