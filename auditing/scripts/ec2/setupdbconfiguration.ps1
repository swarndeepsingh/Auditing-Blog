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

   $script:dbname=$script:dbname.Replace("`r`n","")
    $script:sqlserver=$script:sqlserver.Replace("`r`n","")
    $script:sqlscripts=$script:sqlscripts.Replace("`r`n","")


}
function createdbobjects()
{
    

    $script:tablecreatescriptpath = "$script:sqlscripts\dbo.audittracker.table.sql"
    $script:proccreatescriptpath="$script:sqlscripts\dbo.auditextract.procedure.sql"

    #create db 
    Invoke-Sqlcmd -ServerInstance $servername -query "if not exists(select 1 from sys.databases where name='$script:dbname') create database awsec2auditing" -Database master
    
    #create table
    Invoke-Sqlcmd -ServerInstance $servername -inputfile $script:tablecreatescriptpath -Database $script:dbname

    #create table
    Invoke-Sqlcmd -ServerInstnce $servername -inputfile $tablecreatescriptpath -Database $dbname

    #create procedure
    Invoke-Sqlcmd -ServerInstance $servername -inputfile $script:proccreatescriptpath -Database $dbname
    
    
}

read-config
createdbobjects