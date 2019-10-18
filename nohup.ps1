$path = Get-Location
$r = Get-Random
$name = "Incident$r"

$cmd = "incident.ps1"

if ($args.Count -gt 0)
{
    $cmd = $args[0]
}

#-NoProfile
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-WindowStyle Hidden -File $path\$cmd"
#$trigger =  New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(3)
$trigger =  New-ScheduledTaskTrigger -AtLogOn
$Set = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName $name -Action $action -Trigger $trigger -Settings $set

Start-ScheduledTask -TaskName $name

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
