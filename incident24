Start-Sleep 5

$ifName = (Get-NetAdapter -Physical | Where-Object status -eq "Up").Name

Disable-NetAdapter -Name "$ifName" -Confirm:$false
