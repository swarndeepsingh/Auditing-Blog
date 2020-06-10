

 Param([Parameter(Mandatory=$true)][string]$drservername
 ,[Parameter(Mandatory=$true)][string]$tool
 ,[Parameter(Mandatory=$true)][string]$full
 ,[Parameter(Mandatory=$true)][string]$diff
 ,[Parameter(Mandatory=$true)][string]$trn
 ,[Parameter(Mandatory=$true)][string]$folder)

 write-host $folder

 # example: .\batch_getBackupHeaders.ps1 -folder "\\10.18.25.173\LifespeedPlus_Backups\ALPLSDPRDSQC01\LifeProducts" -tool RGT -drservername DC-CAIRO\DCCAIRO -full yes -diff yes -trn yes
 # example: .\batch_getBackupHeader.ps1 -folder "\\10.18.25.173\LifespeedPlus_Backups\ALPLSDPRDSQC01\LifeProducts" -tool SQL -drservername DC-CAIRO\DCCAIRO -full yes -diff no -trn no

if ($full -eq "yes")
{
    cd C:\DBLOG
	write-host $folder
    .\Get_database_headers_v3.ps1 -folder $folder -backupext dmp -tool $tool -drservername $drservername
	
}
if ($diff -eq "yes")
{
    cd C:\DBLOG
    .\Get_database_headers_v3.ps1 -folder $folder -backupext bak -tool $tool -drservername $drservername
}
if ($trn -eq "yes")
{
    cd C:\DBLOG
    .\Get_database_headers_v3.ps1 -folder $folder -backupext trn -tool $tool -drservername $drservername
}