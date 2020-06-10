# check the path on the server where this is being run and then udpate accordingly
$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS"
import-module sqlps

# Enter the server name below in this format "SQLSERVER:\SQL\<servername>\<instance name or default>"
$srvPath = "SQLSERVER:\SQL\CORPTFS01\Default"

cd $srvpath
$databases = Get-ChildItem databases
$dt = get-date -format yyyyMMddHHmm
$rootfolder = "E:\Backups\MigrationBackups"
foreach ($db in $databases)
{
        $dbname = $db.Name
        Write-Host "Starting Backup $rootfolder\$($dbname)_$($dt)_full.bak"
        
            Backup-SqlDatabase  -Database $($dbname)   -BackupFile "$rootfolder\$($dbname)_$($dt)_full.bak"
            # Backup-SqlDatabase  -Database $($dbname)  -Compression On -CopyOnly -BackupFile "$($dbname)_$($dt)_full.bak"
            Write-Host "successfully Backed up for $db"
} 
