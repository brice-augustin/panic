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

# Attendre que la tâche démarre (TODO : boucle ?)
# Pas trop longtemps, car entretemps la tâche peut avoir fait des dégâts
# causant la perte de la connexion SSH !
Start-Sleep 2

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

# TODO : attendre qu'elle se termine pour rendre la main
# Avantage : possibilité de supprimer les scripts envoyés par le jeu sur le serveur.
# Pour l'instant toutes les tâches se terminent rapidement. Autres cas possibles dans le futur ?
# NON SURTOUT PAS : exemple tâche qui retire l'IP => SSH bloqué !
# nohup doit FORCEMENT se terminer avant la fin de la tâche
