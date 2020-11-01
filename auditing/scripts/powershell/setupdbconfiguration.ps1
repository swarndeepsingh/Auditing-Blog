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
   $script:type=$config.config.type| Out-String
   

   $script:dbname=$script:dbname.Replace("`r`n","")
    $script:sqlserver=$script:sqlserver.Replace("`r`n","")
    $script:sqlscripts=$script:sqlscripts.Replace("`r`n","")
    $script:auditdata=$script:auditdata.Replace("`r`n","")
    $script:auditout=$script:auditout.Replace("`r`n","")
    $script:auditname=$script:auditname.Replace("`r`n","")
    $script:dbauditname=$script:dbauditname.Replace("`r`n","")
    $script:serverspecaudit=$script:serverspecaudit.Replace("`r`n","")
    $script:type= $script:type.Replace("`r`n","")

    if ($script:type -eq "RDS")
    {
        $script:auditdata="D:\rdsdbdata\SQLAudit"
    }

    #$script:dbname='master'


}
function createdbobjects()
{
   
    
    

    $script:tablecreatescriptpath = "$script:sqlscripts\2_dbo.audittracker.table.sql"
    if ($script:type -eq "RDS")
    {
        $script:proccreatescriptpath="$script:sqlscripts\8_dbo.auditextract_json_rds.procedure.sql"
    }
    else {
        $script:proccreatescriptpath="$script:sqlscripts\4_dbo.auditextract_json.procedure.sql"
    }

    #create db 
    Invoke-Sqlcmd -ServerInstance $sqlserver  -Username 'Admin' -Password 'password' -query "if not exists(select 1 from sys.databases where name='$script:dbname') create database $script:dbname" -Database master
    
    write-host "Creating Tracking Table"
    #create table
    Invoke-Sqlcmd -ServerInstance $sqlserver -inputfile $script:tablecreatescriptpath -Database $script:dbname  -Username 'Admin' -Password 'password'


    #create procedure
    write-host "Creating Procedure"
    Invoke-Sqlcmd -ServerInstance $sqlserver -inputfile $script:proccreatescriptpath -Database $dbname  -Username 'Admin' -Password 'password'
    
    
}

function setupauditobjects()
{
    $script:masteraudit = "$script:sqlscripts\5_masteraudit.audit.sql"
    $script:dbaudit="$script:sqlscripts\6_dbaudit.audit.sql"
    $script:srvauditspec="$script:sqlscripts\7_serverauditspecs.audit.sql"

    #create master audit 
    write-host $script:auditdata
    $var="AUDITPATH=$script:auditdata", "AUDITNAME=$script:auditname"
    Invoke-Sqlcmd -ServerInstance $sqlserver -inputfile $script:masteraudit -Database $script:dbname -Variable $var  -Username 'Admin' -Password 'password'
    
    try
    {
        write-host "Creating Server Audit"
        #create server audit spec
        $var="SERVERAUDIT=$script:auditname","serverauditspec=$script:serverspecaudit"
        Invoke-Sqlcmd -ServerInstance $sqlserver -inputfile $script:srvauditspec -Database $script:dbname -Variable $var -Username 'Admin' -Password 'password' -ErrorAction Stop
    }
    catch
    {
        write-host $_
    }


    try
    {
        #create db audit spec
        $var="AUDITEDDB=$script:dbname","SERVERAUDIT=$script:auditname","DBAUDITNAME=$script:dbauditname"
        Invoke-Sqlcmd -ServerInstance $sqlserver -inputfile $script:dbaudit -Database $script:dbname -Variable $var  -Username 'Admin' -Password 'password' -ErrorAction Stop

    }
    catch
    {
        write-host $_
    }

    
}

read-config
createdbobjects
setupauditobjects