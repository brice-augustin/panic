# https://theitbros.com/how-to-remotely-enable-remote-desktop-using-powershell/
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name 'fDenyTSConnections' -Value 0
# En version anglaise : 'Remote Desktop' ...
Enable-NetFirewallRule -DisplayGroup 'Bureau à distance'
