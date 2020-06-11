Param([Parameter(Mandatory=$true)][string]$backuplocation
,[Parameter(Mandatory=$true)][string]$backupext
,[Parameter(Mandatory=$true)][string]$targetservername
, [Parameter(Mandatory=$true)][string]$trackingserver
,[Parameter(Mandatory=$true)][string]$trackingdb
,[Parameter(Mandatory=$true)][string]$trackingschematable)

# delare variables
$header =""
$headerdetails= @{}

# set module sqlserver
import-module SqlServer

function get-header($backuplocation)
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
$headerdetails["EncryptorType"]=$maxpos["EncryptorType"]

write-host($headerdetails["ServerName"])