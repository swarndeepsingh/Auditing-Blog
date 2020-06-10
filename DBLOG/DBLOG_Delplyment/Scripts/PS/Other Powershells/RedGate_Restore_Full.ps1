clear-host

function copyright 
{
    #clear-host
    write-host "###############################################################################################"  -ForegroundColor DarkYellow
    write-host "#                                                                                             #" -ForegroundColor DarkYellow
    write-host "#                                Red Gate Restore Utility                                     #" -ForegroundColor DarkYellow
    write-host "#                                                                                             #" -ForegroundColor DarkYellow
    write-host "#                                DBLOG Configuration Utility                                  #" -ForegroundColor DarkYellow
    write-host "#                                      globalsql@ebix.com                                     #" -ForegroundColor DarkYellow
    write-host "#                                                                                             #" -ForegroundColor DarkYellow
    write-host "###############################################################################################" `n  -ForegroundColor DarkYellow

    
    write-host `n

}



copyright

$header = @()

$backuplocation = read-host "Enter the Folder Path where the backup files are located for Red Gate with .dmp extenion. The folder should not have any other files"
$servername = read-host "Enter Server Name"
$datafilepath = read-host "Enter Path where the data files will be moved"
$logfilepath = read-host "Enter Path where the log files will be moved"
$pwd = read-host "Enter Encryption Key" -AsSecureString

$pwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd))


$script:rootfolderitems = "F:\testrestore"

foreach ($bkupfile in Get-ChildItem  $script:rootfolderitems | Select-Object basename)
{
   $file=  $script:rootfolderitems + "\" + $bkupfile.basename + ".dmp"
   $header = sqlbackupc.exe -I DBLOG -sql "restore sqbheaderonly from disk = '$file' WITH PASSWORD = '$pwd', SINGLERESULTSET "

   for($i=0; $i -le $header.length-1; $i++)
   {
        if($header[$i] -like "Database Name*" )
        {
            $dbname = $header[$i].Substring($header[$i].indexof(":")+2, $header[$i].Length - $header[$i].indexof(":")-2 )
            Write-Host "Restoring Database $dbname"
            Invoke-SQLCMD -Query "EXECUTE Master..sqlbackup 'Restore Database [$dbname] from DISK = ''$file'' WITH PASSWORD = ''$pwd'', MOVE DATAFILES TO ''$datafilepath'', MOVE LOGFILES TO ''$logfilepath'''" -ServerInstance $servername

            write-host "Restored Database $dbname"
        }
   }
}
