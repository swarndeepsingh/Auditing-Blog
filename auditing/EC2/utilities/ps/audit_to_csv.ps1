Param([Parameter(Mandatory=$true)][string]$outputpath
, [Parameter(Mandatory=$true)][string]$dbname
, [Parameter(Mandatory=$true)][string]$auditpath
, [Parameter(Mandatory=$true)][string]$servername)

function getdatatocsv()
{
    bcp "exec $dbname.dbo.auditextract '$auditpath'"  queryout "$outputpath" -T -w -C OEM -S $servername 
}

