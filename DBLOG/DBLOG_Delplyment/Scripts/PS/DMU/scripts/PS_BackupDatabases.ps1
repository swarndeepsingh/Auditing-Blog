$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS"
import-module sqlps

$srvPath = "SQLSERVER:\SQL\CORPTFS01\Default"

cd $srvpath
$databases = Get-ChildItem databases
$dt = get-date -format yyyyMMddHHmm
$rootfolder = "E:\Backups\MigrationBackups"
foreach ($db in $databases)
{
        $dbname = $db.Name
        Write-Host "Starting Backup $rootfolder\$($dbname)_$($dt)_full.bak"
        
            Backup-SqlDatabase  -Database $($dbname)   -CopyOnly -BackupFile "$rootfolder\$($dbname)_$($dt)_full.bak"
            # Backup-SqlDatabase  -Database $($dbname)  -Compression On -CopyOnly -BackupFile "$($dbname)_$($dt)_full.bak"
            Write-Host "successfully Backed up for $db"
} 
