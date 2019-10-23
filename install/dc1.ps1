# https://theitbros.com/how-to-remotely-enable-remote-desktop-using-powershell/
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name 'fDenyTSConnections' -Value 0

Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 0

New-Item -Path 'HKLM:\Software\Policies\Microsoft\SystemCertificates' -Name 'AuthRoot' –Force

Set-ItemProperty 'HKLM:\Software\Policies\Microsoft\SystemCertificates\AuthRoot' -Name 'DisableRootAutoUpdate' -Value 1

# En version anglaise : 'Remote Desktop' ...
Enable-NetFirewallRule -DisplayGroup 'Bureau à distance'

# Le redémarrage plante assez souvent pour que j'envisage
# de me passer du renommage ...
#Rename-Computer -NewName "DC-1"

#Restart-Computer -Force
