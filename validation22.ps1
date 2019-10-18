# Get-Process retourne les noms des processus sans l'extension !
$prog_list = @("explorer32", "svchost32", "smss32", "csrss32", "iexplore32",
            "acrotray32", "services32", "spoolsv32", "savscan32", "ctfmon32")

$ErrorActionPreference = "Stop"

$found = 0

foreach ($prog in $prog_list)
{
    try
    {
        Get-Process $prog | Out-Null
        $found++
        exit 1
    }
    catch
    {
    }
}

exit 0
