powershell "$env:USERPROFILE\.scripts\scoop\install.ps1"
powershell "$env:USERPROFILE\.scripts\chocolatey\install.ps1"
powershell "$env:USERPROFILE\.scripts\winget\install.ps1"

if (!(Test-Path ~\.cache\starship\init.nu )) {
  nu.exe -c "starship init nu | save ~/.cache/starship/init.nu"
}
