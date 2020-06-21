Param(
    [Parameter(Mandatory=$true)][string]$script:configfile
)

$script:sqlserver=''
$script:sqlscripts=''
$script:dbname=''







function read-config()
{
   $config = Get-Content $script:configfile | out-string | ConvertFrom-Json 
   $script:sqlserver=$config.config.sqlserver| Out-String
   $script:sqlscripts=$config.config.sqlscriptpath | Out-String
   $script:dbname=$config.config.dbname | Out-String

   $script:sqlserver=$script:sqlserver.Replace("`r`n","")
   $script:sqlscript=$script:sqlscript.Replace("`r`n","")
   $script:dbname=$script:dbname.Replace("`r`n","")

   $script:tablecreatescriptpath = "$sqlscripts\dbo.audittracker.table.sql"
   $script:proccreatescriptpath="$sqlscripts\dbo.auditextract.procedure"

}
function createdbobjects()
{
    
    #create db 
    Invoke-Sqlcmd -ServerInstance $servername -query "if not exists(select 1 from sys.databases where name='$script:dbname') create database awsec2auditing" -Database master
    
    #create table
    Invoke-Sqlcmd -ServerInstance $servername -inputfile $script:tablecreatescriptpath -Database $script:dbname

    #create table
    Invoke-Sqlcmd -ServerInstance $servername -inputfile $tablecreatescriptpath -Database $dbname

    #create procedure
    Invoke-Sqlcmd -ServerInstance $servername -inputfile $script:proccreatescriptpath -Database $dbname
    
    #$header =$outputpath+ "\" + "headers.head"
    
    #bcp "exec $dbname.dbo.auditextract '$auditpath'"  queryout "$filename" -T -w -C ACP  -S $servername 
    
    #cmd /c copy $header+$filename $finalfilename
    #remove-item $filename
}

read-config
createdbobjects
# -C OEM 