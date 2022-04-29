# Set-ExecutionPolicy RemoteSigned を実行して、Powershell スクリプトの実行を許可し、Administrators で powershell を開いてこのスクリプトを実行
# https://rcmdnk.com/blog/2021/03/01/computer-windows-network/
# https://github.com/microsoft/WSL/issues/4150#issuecomment-504209723

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
  Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs;
  exit;
}

$ip = bash.exe -c "ip r | grep 'eth0 proto' | cut -d ' ' -f9"
if( ! $ip ){
  Write-Output "The Script Exited, the ip address of WSL 2 cannot be found";
  exit;
}

# All the ports you want to forward separated by comma
$ports=@(3000, 7000);
$ports_a = $ports -join ",";

# Remove Firewall Exception Rules
# Invoke-Expression "Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' ";

# Adding Exception Rules for inbound and outbound Rules
# Invoke-Expression "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Outbound -LocalPort $ports_a -Action Allow -Protocol TCP";
# Invoke-Expression "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Inbound -LocalPort $ports_a -Action Allow -Protocol TCP";

for( $i = 0; $i -lt $ports.length; $i++ ){
  $port = $ports[$i];
  Invoke-Expression "netsh interface portproxy add v4tov4 listenport=$port listenaddress=* connectport=$port connectaddress=$ip";
}

# Show proxies
Invoke-Expression "netsh interface portproxy show v4tov4";
