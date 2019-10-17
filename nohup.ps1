$path = Get-Location
$r = Get-Random
$name = "Incident$r"

#-NoProfile
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-WindowStyle Hidden -File $path\incident.ps1"
$trigger =  New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(3)
$Set = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName $name -Action $action -Trigger $trigger -Settings $set

Start-Sleep 5

$t = Get-Scheduledtaskinfo -TaskName $name

# La tache a reussi ou elle est en cours d'execution
if (($t.LastTaskResult -eq 0) -or ($t.LastTaskResult -eq 267009))
{
    Write-Host OK
    Unregister-Scheduledtask -TaskName $name -Confirm:$false
}
else
{
    Write-Host "NOK"
    Get-Scheduledtaskinfo -TaskName $name
}
