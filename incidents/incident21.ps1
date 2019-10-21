$ifIndex = (Get-NetAdapter -Physical | Where-Object status -eq "Up").ifIndex

Set-DnsClientserveraddress -InterfaceIndex $ifIndex -ServerAddresses ("172.16.110.17")
