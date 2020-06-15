Param([Parameter(Mandatory=$true)][string]$backuplocation
, [Parameter(Mandatory=$true)][string]$trackingserver)

# delare variables
$header =""
$headerdetails= @{}

# set module sqlserver
import-module SqlServer

function get-header()
{
    $header=Invoke-Sqlcmd  -Query "RESTORE HEADERONLY FROM DISK ='$backuplocation';" -ServerInstance "$trackingserver" -Username "sa" -Password "sd12091980"
    $max=$header | Measure-Object -Property Position -Maximum
    
    # pick up the max position
    $maxpos=$header | where-object {$_.Position -eq $max.Maximum}

    $headerdetails["ServerName"]=$maxpos["ServerName"]
    $headerdetails["DatabaseName"]=$maxpos["DatabaseName"]
    $headerdetails["BackupName"]=$maxpos["BackupName"]
    $headerdetails["BackupType"]=$maxpos["BackupType"]
    $headerdetails["Compressed"]=$maxpos["Compressed"]
    $headerdetails["BackupSize"]=$maxpos["BackupSize"]
    $headerdetails["CompressedBackupSize"]=$maxpos["CompressedBackupSize"]
    $headerdetails["FirstLSN"]=$maxpos["FirstLSN"]
    $headerdetails["LastLSN"]=$maxpos["LastLSN"]
    $headerdetails["CheckpointLSN"]=$maxpos["CheckpointLSN"]
    $headerdetails["DatabaseBackupLSN"]=$maxpos["DatabaseBackupLSN"]
    $headerdetails["CompatibilityLevel"]=$maxpos["CompatibilityLevel"]
    $headerdetails["MachineName"]=$maxpos["MachineName"]
    $headerdetails["BeginsLogChain"]=$maxpos["BeginsLogChain"]
    $headerdetails["DifferentialBaseLSN"]=$maxpos["DifferentialBaseLSN"]

    return $headerdetails
}

function save-header()
{
    
    
    $array=get-header $backuplocation $trackingserver
    $array
    $insertquery = "INSERT INTO [dbo].[headerdetails]
    ([backupfilepath]
    ,[sourcedatabasename]
    ,[sourceservername]
    ,[backupname]
    ,[backuptype]
    ,[compressed]
    ,[backupsize]
    ,[compressedbackupsize]
    ,[firstlsn]
    ,[lastlsn]
    ,[checkpointlsn]
    ,[databasebackuplsn]
    ,[compatibilitylevel]
    ,[machinename]
    ,[beginslogchain]
    ,[destinationdatabasename]
    ,datecreated
    )
   
     select
    '$backuplocation',
    '$($array.DatabaseName)',
    '$($array.ServerName)',
    '$($array.BackupName)',
    $($array.BackupType),
    $($array.Compressed),
    $($array.BackupSize),
    $($array.CompressedBackupSize),
    $($array.FirstLSN),
    $($array.LastLSN),
    $($array.CheckpointLSN),
    $($array.DatabaseBackupLSN),
    $($array.CompatibilityLevel),
    '$($array.MachineName)',
    '$($array.BeginsLogChain)',
    '$($array.DatabaseName)',
    getdate()
    "
    write-host ($insertquery)
    Invoke-Sqlcmd  -Query "$insertquery" -ServerInstance "$trackingserver" -database destination_migration  -Username "sa" -Password "sd12091980"

}

function main
{
    save-header
}

main