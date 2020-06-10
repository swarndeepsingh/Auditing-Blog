## BEGINNING ##
#Input Params
param(
[Parameter(mandatory=$true)]
[string] $servername
)

#Import libraries
import-module BITSTransfer

#Import libraries
try
{
import-module BITSTransfer
# import-module sqlps
Add-PSSnapin SqlServerCmdletSnapin100
Add-PSSnapin SqlServerProviderSnapin100
}
catch
{
}


$hostname = hostname


$query = "select btj.Transfer_ID, btj.source, btj.Destination + '\' + right(btj.source, charindex('\', reverse(btj.source))-1)  [destination] from dblog.Backup_transfer_Job btj
join dblog.backup_jobs bj
	on bj.Backup_Job_ID = btj.Backup_Job_ID
join dblog.bits_transfer_job bitj
	on bitj.transfer_id = btj.transfer_id
where btj.status not in ('completed', 'pending') and bitj.hostname = '$hostname'"


function SDS-verifyFiles()
{
    $filelist=invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query $query    
    foreach($file in $filelist)
    {
        write-host $file.destination
        write-host $file.source
        if((Test-Path $file.source) -and (test-path $file.destination))
        {
            $query = "update dblog.bits_transfer_job set jobstatus = 'Completed' where transfer_id = $($file.transfer_id)"
            invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query $query  
            write-host "Updated transfer status to Completed for $($file.transfer_id)"
        }
        else
        {
            write-host "Either transferring or file does not exists"
        }
    }
}


function main()
{
    SDS-verifyFiles
}


main;