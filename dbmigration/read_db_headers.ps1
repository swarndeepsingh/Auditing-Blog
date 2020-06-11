#Param([Parameter(Mandatory=$true)][string]$folder
#,[Parameter(Mandatory=$true)][string]$backupext
#,[Parameter(Mandatory=$true)][string]$targetservername)


$header =""
$headerdetails= @{}
# install-module sqlserver
import-module SqlServer
#Invoke-Sqlcmd  -Query "RESTORE HEADERONLY FROM DISK ='D:\Software\adventure-works-2008r2-oltp.bak';" -ServerInstance "1745DESKTOP" -Username "sa" -Password "sd12091980"
$header=Invoke-Sqlcmd  -Query "RESTORE HEADERONLY FROM DISK ='D:\Software\adventure-works-2008r2-oltp.bak';" -ServerInstance "1745DESKTOP" -Username "sa" -Password "sd12091980"
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
$headerdetails["BeginsLogChain"]=$maxpos["BeginsLogChain"]
$headerdetails["EncryptorType"]=$maxpos["EncryptorType"]

write-host($headerdetails["ServerName"])