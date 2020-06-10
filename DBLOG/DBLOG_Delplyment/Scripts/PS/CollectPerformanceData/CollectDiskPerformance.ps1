
function Load-Modules
{
#Add SMO
Add-Type -Path "C:\Program Files\Microsoft SQL Server\120\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
# Add PS
$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\Microsoft SQL Server\120\Tools\PowerShell\Modules;C:\Windows\System32\WindowsPowerShell\v1.0\Modules"
Import-Module sqlps
}

Load-Modules



clear-host
$computer         = "an3prodsql01" 

$script:vpath = ""
$script:vvalue = ""


$results = @(  "\\$Computer\PhysicalDisk(*)\Avg. Disk sec/Transfer" 
  "\\$Computer\PhysicalDisk(*)\Avg. Disk sec/Read", 
  "\\$Computer\PhysicalDisk(*)\Avg. Disk sec/Write") |% { 
    (Get-Counter -SampleInterval 1 -MaxSamples 10 $_.replace("*","*")).CounterSamples }  | 
    Select-Object Path,CookedValue, TimeStamp
    

    foreach ($res in $results)
    {
        $script:vpath = $res.Path
        $script:vvalue = $res.CookedValue
        $collectiontime = $res.TimeStamp

        if ($script:vvalue -ne 0.00)
        {
            $query = "insert into PerformanceCollection.dbo.Performance_collection_disk (Path, Value, servername, inserttime) values( '$vpath', $vvalue, '$computer', '$collectiontime' )"
        #write-host $query
            invoke-sqlcmd -Query $query -ServerInstance "DBLOG"
        }
    }
    
    
 # invoke-sqlcmd -Query "insert into Performance_collection_disk select " -ServerInstance "an3prodsql01"


