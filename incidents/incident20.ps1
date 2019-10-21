Remove-NetFirewallRule -DisplayName 'Autoriser ICMPv4'
New-NetFirewallRule -DisplayName 'Autoriser ICMPv4' -Direction Inbound -Protocol ICMPv4 -Action Block
