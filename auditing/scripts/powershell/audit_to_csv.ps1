Param(
    [Parameter(Mandatory=$true)][string]$script:configfile
)


function read-config()
{
   $config = Get-Content $script:configfile | out-string | ConvertFrom-Json 
   $script:sqlserver=$config.config.sqlserver| Out-String
   $script:sqlscripts=$config.config.sqlscriptpath | Out-String
   $script:auditdata=$config.config.auditdata| Out-String
   $script:auditout=$config.config.auditout| Out-String
   $script:dbname=$config.config.dbname | Out-String
   $script:s3folder=$config.config.s3rawbucketname | Out-String
   
   
    $script:sqlserver=$script:sqlserver.Replace("`r`n","")
    $script:sqlscripts=$script:sqlscripts.Replace("`r`n","")
    $script:auditdata=$script:auditdata.Replace("`r`n","")
    $script:auditout=$script:auditout.Replace("`r`n","")
    $script:dbname=$script:dbname.Replace("`r`n","")
    $script:s3folder=$script:s3folder.Replace("`r`n","")


}


function getdatatocsv()
{
    $servernamefile = $script:sqlserver.Replace( '\\', '_')
    for($i=1; $i -le 20; $i++)
    {
        $filename=$script:auditout+"\"+"sqlaudit_"+$servernamefile+"_" + $(((get-date).ToUniversalTime()).ToString("yyyyMMddTHHmmssfff"))
        $finalfilename = $filename + ".csv"
        Invoke-Sqlcmd -ServerInstance $script:sqlserver -Query "exec dbo.auditextract '$script:auditdata'" -Database $script:dbname -QueryTimeout 1800 | Export-csv -Path $finalfilename -Delimiter "`t" -NoTypeInformation 
        upload_s3($finalfilename)
    }


    
    
}

function upload_s3($path)
{
    $size=(gci -Path $path | measure -Property Length -S).sum
    if ($size -eq 0)
    {
        remove-item -Path $path
    }
    else
    {
        try
        {

            Write-S3Object   -BucketName $script:s3folder -File $path
        }
        Catch
        {
            write-host "Unable to write to S3"
        }
    }
}
read-config
getdatatocsv
# -C OEM 
