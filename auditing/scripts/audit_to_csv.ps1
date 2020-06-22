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
   
    $script:sqlserver=$script:sqlserver.Replace("`r`n","")
    $script:sqlscripts=$script:sqlscripts.Replace("`r`n","")
    $script:auditdata=$script:auditdata.Replace("`r`n","")
    $script:auditout=$script:auditout.Replace("`r`n","")
    $script:dbname=$script:dbname.Replace("`r`n","")


}


function getdatatocsv()
{
    $servernamefile = $script:sqlserver.Replace( '\\', '_')
    for($i=1; $i -le 20; $i++)
    {
        $filename=$script:auditout+"\"+"sqlaudit_"+$servernamefile+"_" + $(((get-date).ToUniversalTime()).ToString("yyyyMMddTHHmmssfff"))
        $finalfilename = $filename + ".csv"
        Invoke-Sqlcmd -ServerInstance $script:sqlserver -Query "exec dbo.auditextract '$script:auditdata'" -Database $script:dbname -QueryTimeout 1800 | Export-csv -Path $finalfilename -Delimiter "`t" -NoTypeInformation 
        sleep -Milliseconds 100
    }
    
    
}
read-config
getdatatocsv
# -C OEM 
