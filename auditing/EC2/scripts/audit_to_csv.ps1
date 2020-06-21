Param([Parameter(Mandatory=$true)][string]$outputpath
, [Parameter(Mandatory=$true)][string]$dbname
, [Parameter(Mandatory=$true)][string]$auditpath
, [Parameter(Mandatory=$true)][string]$servername)

function getdatatocsv()
{
    $servernamefile = $servername -replace '\\', ' '
    $filename=$outputpath+"\"+"sqlaudit_"+$servernamefile+"_" + $(((get-date).ToUniversalTime()).ToString("yyyyMMddTHHmmssfff"))
    $finalfilename = $filename + ".csv"
     
    Invoke-Sqlcmd -ServerInstance $servername -Query "exec dbo.auditextract '$auditpath'" -Database $dbname | Export-csv -Path $finalfilename -Delimiter "`t" -NoTypeInformation
    
    
    #$header =$outputpath+ "\" + "headers.head"
    
    #bcp "exec $dbname.dbo.auditextract '$auditpath'"  queryout "$filename" -T -w -C ACP  -S $servername 
    
    #cmd /c copy $header+$filename $finalfilename
    #remove-item $filename
}

getdatatocsv
# -C OEM 
