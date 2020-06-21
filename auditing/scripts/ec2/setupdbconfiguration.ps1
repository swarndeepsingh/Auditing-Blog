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
   $script:auditdata=$config.config.auditdata| Out-String
   $script:auditout=$config.config.auditout| Out-String
   $script:auditname=$config.config.auditname| Out-String

   $script:dbname=$script:dbname.Replace("`r`n","")
    $script:sqlserver=$script:sqlserver.Replace("`r`n","")
    $script:sqlscripts=$script:sqlscripts.Replace("`r`n","")
    $script:auditdata=$script:auditdata.Replace("`r`n","")
    $script:auditout=$script:auditout.Replace("`r`n","")
    $script:auditname=$script:auditname.Replace("`r`n","")
    $script:dbauditname=$script:dbauditname.Replace("`r`n","")


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
    Invoke-Sqlcmd -ServerInstance $servername -inputfile $tablecreatescriptpath -Database $dbname

    #create procedure
    Invoke-Sqlcmd -ServerInstance $servername -inputfile $script:proccreatescriptpath -Database $dbname
    
    
}

function setupauditobjects()
{
    $script:masteraudit = "$script:sqlscripts\masteraudit.audit.sql"
    $script:dbaudit="$script:sqlscripts\dbaudit.audit.sql"

     #create masteraudit 
     $var="AUDITPATH=$script:auditdata", "AUDITNAME=$script:auditname"
     Invoke-Sqlcmd -ServerInstance $servername -inputfile $script:masteraudit -Database $script:dbname -Variable $var

     #create dbaudit
     $var="AUDITEDDB=$script:dbname","SERVERAUDIT=$script:auditname","DBAUDITNAME=$script:dbauditname"
     Invoke-Sqlcmd -ServerInstance $servername -inputfile $script:dbaudit -Database $script:dbname -Variable $var
    
}

read-config
createdbobjects
setupauditobjects