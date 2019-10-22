# https://theitbros.com/how-to-remotely-enable-remote-desktop-using-powershell/
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name 'fDenyTSConnections' -Value 0

Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 0

# En version anglaise : 'Remote Desktop' ...
Enable-NetFirewallRule -DisplayGroup 'Bureau � distance'
