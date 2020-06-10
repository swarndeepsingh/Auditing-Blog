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


function SDS-Set-TransferStatus ($jobid, $transferstatus,$owneraccount,  $errorcount, $errorcontext, $errorcondition, $bytestotal, $bytestransferred, $files, $filestransferred, $starttime, $transferredtime, $completedtime)
{

   

    $query =  "update dblog.bits_transfer_job
          set JobStatus = '$transferstatus', owneraccount = '$owneraccount', errorcount = '$errorcount', errorcontext = '$errorcontext'
          ,errorcondition = '$errorcontext', BytesTotal = '$bytestotal', BytesTransferred = '$bytestransferred', Files = '$files', FilesTransferred = '$filestransferred'
          , starttime = '$starttime'
          -- , transferredtime = case '$transferredtime' when '1900-01-01 00:00:00.000' then NULL else '$transferredtime' end
          , transferredtime = case when isdate('$transferredtime')= 1 then '$transferredtime' else NULL END
          --, completedtime = case '$completedtime' when '1900-01-01 00:00:00.000' then NULL else '$completedtime' end
          , completedtime = case when isdate('$completedtime') = 1 then '$completedtime' else NULL END
          --, LastStatusTime = case '$transferredtime' when '1900-01-01 00:00:00.000' then getdate() else '$transferredtime' end
          , LastStatusTime = getdate()
          where bitsjobid = '$jobid'
          " 
      

         invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query $query

         if ($transferstatus -eq "Transferred")
         {
            try
            {
               Get-BitsTransfer -jobid $jobid | Complete-BitsTransfer

               invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query "update dblog.bits_transfer_job set jobstatus ='Completed' where bitsjobid = '$jobid'"
           }
           catch
           {
                $errormessage = $_.Exception.Message

                write-host "Cannot complete the transfer, exception - $errormessage"
           }
         }
         

}




$jobid = invoke-sqlcmd -ServerInstance $servername -Database 'DBLOG' -query "select bitsjobid  from dblog.bits_transfer_job where isnull(jobstatus,'') <> 'Completed' and hostname = '$env:computername'"



foreach($bitsjobid in $jobid)
{

    try
    {
        write-host "Getting status for $($bitsjobid.bitsjobid)"
        $bits = Get-BitsTransfer -jobid $bitsjobid.bitsjobid
        SDS-Set-TransferStatus $bits.JobId  $bits.jobstate $bits.owneraccount $bits.TransientErrorCount $bits.errorcontext $bits.errorcondition $bits.bytestotal $bits.bytestransferred $bits.filestotal $bits.filestransferred $bits.creationtime $bits.transfercompletiontime $bits.transfercompletiontime 
    }
    catch
    {
                $errormessage = $_.Exception.Message

                write-host "Cannot get transfer status, exception - $errormessage"
    }
}



#if ($bits = Get-BitsTransfer  -ea 0)
#{
#	switch ($bits.jobstate)
#	{
#		"transferred" { SDS-Set-TransferStatus }
#		"transferring" { }
#		"suspended" { }
#		"error" { }
#		default { }
#	}
#}


