

clear-host

Import-Module sqlps


#Function connect-SQL([string] $srvname)


$machine = "wsprds051\prdb20028"

$database = "CMDBSQL"

$script1 = 'select distinct sql_network_name from instances'

 $server = new-object Microsoft.SqlServer.Management.Smo.Server("$machine")
    $db = $server.Databases.Item($database) 
    $result1=$db.ExecuteWithResults("$script1")
    $array0 = $result1.Tables[0]


$array1=Import-CSV "C:\swarn\others\listOfServers.csv" | Select AffectedObjectName 

#compare-object $array0 $array1 | Select AffectedObjectName



foreach ($servername in $array1)
{

    foreach ($machinename in $array0)
    {
        if ($servername.AffectedObjectName.Substring(0, $servername.AffectedObjectName.IndexOf(".")) = $machinename)
        {
            $servername
        }

    }

    $servername.AffectedObjectName.Substring(0, $servername.AffectedObjectName.IndexOf("."))
    #$servername.SubString(0, $servername.AffectedObjectNameIndexOf.IndexOF("."))
    #foreach($machinename in $array0)
    #{
    #    if ($servername -eq $machinename)
    #    {
    #        $machinename

    #    }
    #}
}


#WAPRDS024
 
