Param(
    [Parameter(Mandatory=$true)][string]$script:configfile
)

#Import-Module SQLServer

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
   $script:dbauditname=$config.config.dbauditname| Out-String
   $script:serverspecaudit=$config.config.serverspecaudit| Out-String
   

   $script:dbname=$script:dbname.Replace("`r`n","")
    $script:sqlserver=$script:sqlserver.Replace("`r`n","")
    $script:sqlscripts=$script:sqlscripts.Replace("`r`n","")
    $script:auditdata=$script:auditdata.Replace("`r`n","")
    $script:auditout=$script:auditout.Replace("`r`n","")
    $script:auditname=$script:auditname.Replace("`r`n","")
    $script:dbauditname=$script:dbauditname.Replace("`r`n","")
    $script:serverspecaudit=$script:serverspecaudit.Replace("`r`n","")

    #$script:dbname='master'


}
function createdbobjects()
{
   
    
    

    $script:tablecreatescriptpath = "$script:sqlscripts\2_dbo.audittracker.table.sql"
    $script:proccreatescriptpath="$script:sqlscripts\4_dbo.auditextract_json.procedure.sql"

    #create db 
    Invoke-Sqlcmd -ServerInstance $sqlserver -query "if not exists(select 1 from sys.databases where name='$script:dbname') create database $script:dbname" -Database master
    
    write-host "Creating Tracking Table"
    #create table
    Invoke-Sqlcmd -ServerInstance $sqlserver -inputfile $script:tablecreatescriptpath -Database $script:dbname


    #create procedure
    write-host "Creating Procedure"
    Invoke-Sqlcmd -ServerInstance $sqlserver -inputfile $script:proccreatescriptpath -Database $dbname
    
    
}

function setupauditobjects()
{
    $script:masteraudit = "$script:sqlscripts\5_masteraudit.audit.sql"
    $script:dbaudit="$script:sqlscripts\6_dbaudit.audit.sql"
    $script:srvauditspec="$script:sqlscripts\7_serverauditspecs.audit.sql"

    #create master audit 
    $var="AUDITPATH=$script:auditdata", "AUDITNAME=$script:auditname"
    Invoke-Sqlcmd -ServerInstance $sqlserver -inputfile $script:masteraudit -Database $script:dbname -Variable $var
    
    try
    {
        write-host "Creating Server Audit"
        #create server audit spec
        $var="SERVERAUDIT=$script:auditname","serverauditspec=$script:serverspecaudit"
        Invoke-Sqlcmd -ServerInstance $sqlserver -inputfile $script:srvauditspec -Database $script:dbname -Variable $var -ErrorAction Stop
    }
    catch
    {
        write_host $_
    }


    try
    {
        #create db audit spec
        $var="AUDITEDDB=$script:dbname","SERVERAUDIT=$script:auditname","DBAUDITNAME=$script:dbauditname"
        Invoke-Sqlcmd -ServerInstance $sqlserver -inputfile $script:dbaudit -Database $script:dbname -Variable $var -ErrorAction Stop

    }
    catch
    {
        write-host $_
    }

    
}

read-config
createdbobjects
setupauditobjects