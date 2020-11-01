Param(
    [Parameter(Mandatory=$true)][string]$script:configfile
)

#Import-Module sqlserver

function read-config()
{
   $config = Get-Content $script:configfile | out-string | ConvertFrom-Json 
   $script:sqlserver=$config.config.sqlserver| Out-String
   $script:sqlscripts=$config.config.sqlscriptpath | Out-String
   $script:auditdata=$config.config.auditdata| Out-String
   $script:auditout=$config.config.auditout| Out-String
   $script:dbname=$config.config.dbname | Out-String
   $script:type=$config.config.type | Out-String
   
    $script:sqlserver=$script:sqlserver.Replace("`r`n","")
    $script:sqlscripts=$script:sqlscripts.Replace("`r`n","")
    $script:auditdata=$script:auditdata.Replace("`r`n","")
    $script:auditout=$script:auditout.Replace("`r`n","")
    $script:dbname=$script:dbname.Replace("`r`n","")
    $script:type=$script:type.Replace("`r`n","")

    if ($script:type -eq "RDS")
    {
        $script:auditdata="D:\rdsdbdata\SQLAudit"
    }


}


function getdatatocsv()
{
    $servernamefile = $script:sqlserver.Replace( '\\', '_')
    for($i=1; $i -le 20; $i++)
    {
        $filename=$script:auditout+"\"+"sqlaudit_"+$servernamefile+"_" + $(((get-date).ToUniversalTime()).ToString("yyyyMMddTHHmmssfff"))
        $finalfilename = $filename + ".log"
        #Invoke-Sqlcmd -ServerInstance $script:sqlserver -Query "exec dbo.auditextract_json_1" -Database $script:dbname -QueryTimeout 1800  | Export-csv -Path $finalfilename  -Delimiter "`t" -NoTypeInformation -Force -Encoding ASCII |  Select-Object -Skip 1 | % {$_ -replace '"', ""} 
        #Invoke-Sqlcmd -ServerInstance $script:sqlserver -Query "exec dbo.auditextract_json_1" -Database $script:dbname -QueryTimeout 1800  | ConvertTo-Csv -Delimiter "`t" -NoTypeInformation |  Select-Object -Skip 1  | Out-File ($finalfilename) -Force -Encoding ascii #| % {$_ -replace '"', ""}
        Invoke-Sqlcmd -ServerInstance $script:sqlserver -Query "exec dbo.auditextract_json '$script:auditdata'" -Database $script:dbname -QueryTimeout 6000   -Username 'Admin' -Password 'password'  | Select-Object * -ExcludeProperty ItemArray, Table, RowError, RowState, HasErrors | ConvertTo-Json -Compress | % {$_ -replace '},',"}`r`n"} | % {$_ -replace '\]',''} |% {$_ -replace '\[',''} | Out-File ($finalfilename)  -Force -Encoding ascii #| % {$_ -replace '"', ""} |  Select-Object -Skip 1
        #upload_s3($finalfilename)
    }


    
    
}
<# 
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
} #>
read-config
getdatatocsv
# -C OEM 
