## BEGINNING ##
#Input Params
param(
[Parameter(mandatory=$true)]
[string] $servername
)

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

# declare variables

$hostname=hostname


$script:runningLogXfer
$script:runningdiffXfer
$script:runningFullXfer


$script:FullXferLimit
$script:LogXferLimit
$script:DiffXferLimit
$script:date = get-date

function SDS-Get-RunningTransferCountsfromDB()
{

#Check run count

        $script:runningLogXfer = invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query "select COUNT(1) as [count] from dblog.backup_transfer_job btj
        join dblog.Backup_info bi
	        on bi.Backup_ID = btj.Backup_ID
		join dblog.bits_transfer_job bitj
			on bitj.Transfer_ID = btj.Transfer_ID
         where btj.status  not in ('completed', 'pending', 'obsoleted')  and bi.transfermethod='BITS' and bi.BackupType = 'L' and bitj.HostName = '$hostname'"


        $script:runningdiffXfer = invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query "select COUNT(1) as [count] from dblog.backup_transfer_job btj
        join dblog.Backup_info bi
	        on bi.Backup_ID = btj.Backup_ID
		join dblog.bits_transfer_job bitj
			on bitj.Transfer_ID = btj.Transfer_ID
         where btj.status  not in ('completed', 'pending', 'obsoleted')  and bi.transfermethod='BITS' and bi.BackupType = 'I' and bitj.HostName = '$hostname'"


          $script:runningFullXfer = invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query "select COUNT(1) as [count] from dblog.backup_transfer_job btj
        join dblog.Backup_info bi
	        on bi.Backup_ID = btj.Backup_ID
		join dblog.bits_transfer_job bitj
			on bitj.Transfer_ID = btj.Transfer_ID
         where btj.status  not in ('completed', 'pending', 'obsoleted')  and bi.transfermethod='BITS' and bi.BackupType = 'D' and bitj.HostName = '$hostname'"
}



function SDS-Get-TranferCountLimit()
{

    # get current properties
    $script:FullXferLimit = invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query "select value from DBLog.bits_transfer_properties where property = 'FullBackupInstances' and property1 = '$hostname'"

    $script:LogXferLimit = invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query "select value from DBLog.bits_transfer_properties where property = 'LogBackupInstances' and property1 = '$hostname'"

    $script:DiffXferLimit = invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query "select value from DBLog.bits_transfer_properties where property = 'DiffBackupInstances' and property1 = '$hostname'"
}





# check if more instances can be run for full and then start it

function SDS-Xfer-Full-Backup
{
	$hstname = $env:computername

    if ($script:runningFullXfer.count -lt $script:FullXferLimit.value)
    {
    
         $transferjob = invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query "

        select top 1 btj.Transfer_ID, btj.Backup_ID, btj.Source, btj.Destination, bi.transfermethod 
        from dblog.backup_transfer_job btj
        join dblog.Backup_info bi
	        on bi.Backup_ID = btj.Backup_ID
	       Join dblog.Backup_Jobs bj
			on bj.Backup_Job_ID = btj.Backup_Job_ID
         where btj.status ='pending' and bi.transfermethod='BITS' and bi.backuptype = 'D' 
         and bj.retainUntil_local > GETDATE()+5
         order by transfer_id asc"

        $transferid = $transferjob.Transfer_ID
        $source = $transferjob.Source
        $destination = $transferjob.Destination


        if($source -ne $null)
        {

            $query ="
                insert into dblog.bits_transfer_job (transfer_id, bitsjobid,                 starttime,hostname)
                values ($transferid, 'Transferring', getdate(), '$hstname')"


                try
                {

                    invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query $query
                }
                catch 
                {
                    Write-Host "Failed to insert new transfer job in table"
                    $errormsg = $_.Exception.Message
                    add-content -path "bits.log" -value "$date - Failed to insert new transferid $transferid job $errormsg"
                    return
                }

                #$file = get-bitstransfer | select -Expandproperty filelist | where {$_.localname -eq "$source"}


            
                try
                {
                    $transferstatus = start-bitstransfer $source $destination -TransferType upload -Asynchronous
                    $jobid = $transferstatus.jobid
                    $jobstatus = $transferstatus.jobstatus
                    $owneraccount = $transferstatus.owneraccount
                    $errcount = $transferstatus.errorcount
                    $errcontext = $transferstatus.errorcontext
                    $errcond = $transferstatus.errorcondition
                    $bytestotal=$transferstatus.bytestotal
                    $files = $transferstatus.files
                    $filexfer = $transferstatus.filestransferred
                    $xfertime = $transferstatus.transferredtime
                    $completetime = $transferstatus.completedtime
                    $hstname = $env:computername
                }
                catch
                {
                    Write-Host "Failed to setup new transfer job in table"
                    $errormsg = $_.Exception.Message
                    add-content -path "bits.log" -value "$date - Failed to setup new transferid $transferid job $errormsg in BITS"
                    return
                }



                if ($jobid -ne '')
                {
                     # udpate job
                    # invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query "update dblog.backup_transfer_job set status = 'Copying', startdate=getdate(), message='Copying using BITS' where transfer_id = $transferid"
                    #update BITS row
                    $queryupdate ="
                    update dblog.bits_transfer_job set bitsjobid='$jobid', JobStatus='$jobstatus', owneraccount='$owneraccount', errorcount='$errcount', errorcontext='$errcontext', errorcondition='$errcond', 
                    bytestotal='$bytestotal',bytestransferred='0', files='$files', filestransferred='$filexfer', 
                    starttime=getdate(), transferredtime='$xfertime', completedtime'$completetime',hostname='$hstname'
                    where transfer_id = $transferid
                     "
                     write-host $queryupdate
                    invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query $queryupdate
                
                }

                {
                        write-host "Job ID is not valid for $transferid"
                }
            }
            else
            {
                write-host "No file found for full backup transfer"
            }
        }


        else
        {
            write-host "Full backup transfer request denied, current number of instances allowed are $($script:FullXferLimit.value) and running instances are $($script:runningFullXfer.count)"
    
        }
}








function SDS-Xfer-Diff-Backup
{

		$hstname = $env:computername

        # check if more instances can be run for diff and then start it


        if ($script:runningdiffXfer.count -lt $script:DiffXferLimit.value)
        {
    
             $transferjob = invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query "

            select top 1 btj.Transfer_ID, btj.Backup_ID, btj.Source, btj.Destination, bi.transfermethod 
            from dblog.backup_transfer_job btj
            join dblog.Backup_info bi
	            on bi.Backup_ID = btj.Backup_ID
	           Join dblog.Backup_Jobs bj
			    on bj.Backup_Job_ID = btj.Backup_Job_ID
             where btj.status ='pending' and bi.transfermethod='BITS' and bi.backuptype = 'I' 
             and bj.retainUntil_local > GETDATE()+5
             order by transfer_id asc"

            $transferid = $transferjob.Transfer_ID
            $source = $transferjob.Source
            $destination = $transferjob.Destination

            #write-host $source
            #write-host $destination

            if($source -ne $null)
            {
                $query ="
                insert into dblog.bits_transfer_job (transfer_id, bitsjobid,                 starttime,hostname)
                values ($transferid, 'Transferring', getdate(), '$hstname')"


                try
                {

                    invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query $query
                }
                catch 
                {
                    Write-Host "Failed to insert new transfer job in table"
                    $errormsg = $_.Exception.Message
                    add-content -path "bits.log" -value "$date - Failed to insert new transferid $transferid job $errormsg"
                    return
                }

                #$file = get-bitstransfer | select -Expandproperty filelist | where {$_.localname -eq "$source"}


            
                try
                {
                    $transferstatus = start-bitstransfer $source $destination -TransferType upload -Asynchronous
                    $jobid = $transferstatus.jobid
                    $jobstatus = $transferstatus.jobstatus
                    $owneraccount = $transferstatus.owneraccount
                    $errcount = $transferstatus.errorcount
                    $errcontext = $transferstatus.errorcontext
                    $errcond = $transferstatus.errorcondition
                    $bytestotal=$transferstatus.bytestotal
                    $files = $transferstatus.files
                    $filexfer = $transferstatus.filestransferred
                    $xfertime = $transferstatus.transferredtime
                    $completetime = $transferstatus.completedtime
                    $hstname = $env:computername
                }
                catch
                {
                    Write-Host "Failed to setup new transfer job in table"
                    $errormsg = $_.Exception.Message
                    add-content -path "bits.log" -value "$date - Failed to setup new transferid $transferid job $errormsg in BITS"
                    return
                }



                if ($jobid -ne '')
                {
                     # udpate job
                    # invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query "update dblog.backup_transfer_job set status = 'Copying', startdate=getdate(), message='Copying using BITS' where transfer_id = $transferid"
                    #update BITS row
                    $queryupdate ="
                    update dblog.bits_transfer_job set bitsjobid='$jobid', JobStatus='$jobstatus', owneraccount='$owneraccount', errorcount='$errcount', errorcontext='$errcontext', errorcondition='$errcond', 
                    bytestotal='$bytestotal',bytestransferred='0', files='$files', filestransferred='$filexfer', 
                    starttime=getdate(), transferredtime='$xfertime', completedtime'$completetime',hostname='$hstname'
                    where transfer_id = $transferid
                     "

                    invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query $queryupdate
                
                }

                {
                        write-host "Job ID is not valid for $transferid"
                }
            }
            else
            {
                write-host "No file found for full backup transfer"
            }
        }


        
        else
        {
            write-host "Differential Backup Transfer request denied, current number of instances allowed are $($script:DiffXferLimit.value) and running instances are $($script:runningdiffXfer.count)"
    
        }
}




function SDS-Xfer-Log-Backup
{

	$hstname = $env:computername

    # check if more instances can be run for LOG and then start it

    if ($script:runningLogXfer.count -lt $script:LogXferLimit.value)
    {
    
         $transferjob = invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query "

    select top 1 btj.Transfer_ID, btj.Backup_ID, btj.Source, btj.Destination, bi.transfermethod 
        from dblog.backup_transfer_job btj
        join dblog.Backup_info bi
	        on bi.Backup_ID = btj.Backup_ID
	       Join dblog.Backup_Jobs bj
			on bj.Backup_Job_ID = btj.Backup_Job_ID
         where btj.status ='pending' and bi.transfermethod='BITS' and bi.backuptype = 'L' 
         and bj.retainUntil_local > GETDATE()+5
         order by transfer_id asc"

        $transferid = $transferjob.Transfer_ID
        $source = $transferjob.Source
        $destination = $transferjob.Destination

       if($source -ne $null)
       {


            $query ="
                insert into dblog.bits_transfer_job (transfer_id, bitsjobid,                 starttime,hostname)
                values ($transferid, 'Transferring', getdate(), '$hstname')"


                try
                {

                    invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query $query
                }
                catch 
                {
                    Write-Host "Failed to insert new transfer job in table"
                    $errormsg = $_.Exception.Message
                    add-content -path "bits.log" -value "$date - Failed to insert new transferid $transferid job $errormsg"
                    return
                }

                #$file = get-bitstransfer | select -Expandproperty filelist | where {$_.localname -eq "$source"}


            
                try
                {
                    $transferstatus = start-bitstransfer $source $destination -TransferType upload -Asynchronous
                    $jobid = $transferstatus.jobid
                    $jobstatus = $transferstatus.jobstatus
                    $owneraccount = $transferstatus.owneraccount
                    $errcount = $transferstatus.errorcount
                    $errcontext = $transferstatus.errorcontext
                    $errcond = $transferstatus.errorcondition
                    $bytestotal=$transferstatus.bytestotal
                    $files = $transferstatus.files
                    $filexfer = $transferstatus.filestransferred
                    $xfertime = $transferstatus.transferredtime
                    $completetime = $transferstatus.completedtime
                    $hstname = $env:computername
                }
                catch
                {
                    Write-Host "Failed to setup new transfer job in table"
                    $errormsg = $_.Exception.Message
                    add-content -path "bits.log" -value "$date - Failed to setup new transferid $transferid job $errormsg in BITS"
                    return
                }



                if ($jobid -ne '')
                {
                     # udpate job
                    # invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query "update dblog.backup_transfer_job set status = 'Copying', startdate=getdate(), message='Copying using BITS' where transfer_id = $transferid"
                    #update BITS row
                    $queryupdate ="
                    update dblog.bits_transfer_job set bitsjobid='$jobid', JobStatus='$jobstatus', owneraccount='$owneraccount', errorcount='$errcount', errorcontext='$errcontext', errorcondition='$errcond', 
                    bytestotal='$bytestotal',bytestransferred='0', files='$files', filestransferred='$filexfer', 
                    starttime=getdate(), transferredtime='$xfertime', completedtime'$completetime',hostname='$hstname'
                    where transfer_id = $transferid
                     "

                    invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query $queryupdate
                
                }

                {
                        write-host "Job ID is not valid for $transferid"
                }
            }
            else
            {
                write-host "No file found for full backup transfer"
            }
        }
    else
    {
        write-host "Log backup transfer request denied, current number of instances allowed are $($script:LogXferLimit.value) and running instances are $($script:runningLogXfer.count)"
    
    }
}


function SDS-main
{

    

    SDS-Get-RunningTransferCountsfromDB
    SDS-Get-TranferCountLimit
    SDS-Xfer-Full-Backup
    #SDS-Xfer-Diff-Backup
    SDS-Xfer-Log-Backup
}


# call main function

SDS-Main








## END ##