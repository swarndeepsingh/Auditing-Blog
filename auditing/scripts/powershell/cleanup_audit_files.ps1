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
   
   
    $script:sqlserver=$script:sqlserver.Replace("`r`n","")
    $script:sqlscripts=$script:sqlscripts.Replace("`r`n","")
    $script:auditdata=$script:auditdata.Replace("`r`n","")
    $script:auditout=$script:auditout.Replace("`r`n","")
    $script:dbname=$script:dbname.Replace("`r`n","")

}

read-config

foreach ($i in get-childItem($script:auditdata))
{
    write-host $i
    Invoke-Sqlcmd -ServerInstance $script:sqlserver -Query "
}