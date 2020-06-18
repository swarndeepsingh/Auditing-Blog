Param([Parameter(Mandatory=$true)][string]$outputpath
, [Parameter(Mandatory=$true)][string]$dbname
, [Parameter(Mandatory=$true)][string]$auditpath
, [Parameter(Mandatory=$true)][string]$servername)

function getdatatocsv()
{
    $servernamefile = $servername -replace '\\', ' '
    $filename=$outputpath+"\"+"sqlaudit_"+$servernamefile+"_" + $(((get-date).ToUniversalTime()).ToString("yyyyMMddTHHmmssfff"))
    $header =$outputpath+ "\" + "headers.head"
    $finalfilename = $filename + ".csv"
    bcp "exec $dbname.dbo.auditextract '$auditpath'"  queryout "$filename" -T -w -C OEM -S $servername 
    
    cmd /c copy $header+$filename $finalfilename
    remove-item $filename
}

getdatatocsv
