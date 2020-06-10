#Input Parameters
Param([Parameter(Mandatory=$true)][string]$folder
,[Parameter(Mandatory=$true)][string]$backupext
,[Parameter(Mandatory=$true)][string]$tool
,[Parameter(Mandatory=$true)][string]$drservername)


# Get Libraries
Import-Module SQLPS
Add-Type -Path "C:\Program Files\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
Add-Type -Assembly 'Microsoft.SqlServer.BatchParser, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91'

$script:debug = "on"

# clear the stuff
clear-host



 #$folder = "\\an3prodsql01b\Backups\AN3PRODSQL01\AnnuityTransactions"
 
 $script:backuptool = $tool
 $script:drserver = $drservername
  $headerdetails= @("nothing","nothing","nothing","nothing","nothing","nothing","nothing","nothing","nothing","nothing")
 $script:filename=@()
 $script:db = ""
 $script:table=@()


 function get-Event($message)
 {
    $logFileExists = Get-ChildItem HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application\dblogshippingpowershell*
    if (!$logFileExists)
    {
        New-EventLog -LogName Application -Source "DBLOGShippingPowershell"
    }
    if($script:debug -eq "on")
    {
        Write-EventLog -LogName "Application" -Source "DBLOGShippingPowershell" -EventID 3001 -EntryType Error -Message $message
        write-host $message    
    } 

    if ($script:debug -eq "off")
    {
        Write-EventLog -LogName "Application" -Source "DBLOGShippingPowershell" -EventID 3001 -EntryType Error -Message $message
    }
 }

 function Set-connection($drmachine)
{
    try
    {
        $smo = New-Object Microsoft.SQLServer.Management.smo.server($drmachine) 
        #$smo
        
    }
    
    catch
    {
        get-event "Error Establishing connection to  $machine"
        get-Event $_.Exception.Message
    }

    return $smo
}


function get-Data($srv)
{
        $script:db = $srv.Databases.Item("DBLOGDR")

        #$script:db

        #get-Event $srv
        $sql = "Select filename from backupheaders"
        $result = $script:db.ExecuteWithResults($sql)
        #$result
        $table=$result.Tables[0]

        return $table
}







 function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}

#$drivearray=@(ls function:[d-z]: -n|?{!(test-path $_)})
#$sourcemapdrive = $drivearray[$drivearray.length-1]
    
function read-RedGateHeader()
{  
    #get-Event $script:filename
    
    $fileitems = Get-ChildItem  $folder\* -include *.$backupext | select-object name | Sort-Object name
    $tablefiles = $script:table.filename

    #get-Event $tablefiles

    if ($tablefiles -ne $null)
    {
        $filestoberead = compare-object -ReferenceObject $fileitems.name -DifferenceObject $tablefiles  | Where-Object {$_.SideIndicator -eq "<="} | select-object "InputObject"
    }

    elseif ($tablefiles -eq $null)
    {
        $filestoberead = compare-object -ReferenceObject $fileitems.name -DifferenceObject @("nofileindatabase")  | Where-Object {$_.SideIndicator -eq "<="} | select-object "InputObject"
    }

         
    if ($script:backuptool -eq "RGT")
    {
       
        foreach ($bkupfile in $filestoberead )
        {
                
                get-Event "Reading Header Information from   $($bkupfile.Inputobject)"
          
                       $header = sqlbackupc.exe -I $script:DRSERVER -sql "restore sqbheaderonly from disk = '$folder\$($bkupfile.inputobject)' WITH PASSWORD = 'N0tBl4nk', SINGLERESULTSET"

                          for ($i=0; $i -le $header.length-1; $i++)
                           {
                                if($header[$i] -like "Database Name*" )
                                {
                                    $headerdetails[0]= $header[$i]
                        
                                }

                                if($header[$i] -like "Server name*" )
                                {
                                    $headerdetails[1]= $header[$i]
                        
                                }

                                if($header[$i] -like "First LSN*" )
                                {
                                    $headerdetails[2]= $header[$i]
                        
                                }

                                if($header[$i] -like "Last LSN*" )
                                {
                                    $headerdetails[3]= $header[$i]
                        
                                }

                                if($header[$i] -like "Checkpoint LSN*" )
                                {
                                    $headerdetails[4]= $header[$i]
                        
                                }

                                if($header[$i] -like "Database Backup LSN*" )
                                {
                                    $headerdetails[5]= $header[$i]
                        
                                }

                                if($header[$i] -like "Native Backup Size*" )
                                {
                                    $headerdetails[6]= $header[$i]
                        
                                }

                                if($header[$i] -like "Database Size*" )
                                {
                                    $headerdetails[7]= $header[$i]
                        
                                }

                                if($header[$i] -like "SQL Backup exit code*" ) # check for error
                                {
                                    $headerdetails[8]= $header[$i]
                        
                                }

                                if($header[$i] -like "Backup type*" )
                                {
                                    $headerdetails[9]= $header[$i]
                        
                                }
                           }


                           $headerdetails[0]= $headerdetails[0].Substring($headerdetails[0].indexof(":")+1, $headerdetails[0].Length - $headerdetails[0].indexof(":")-1 )
                           $headerdetails[1]= $headerdetails[1].Substring($headerdetails[1].indexof(":")+1, $headerdetails[1].Length - $headerdetails[1].indexof(":")-1 )
                           $headerdetails[2]= $headerdetails[2].Substring($headerdetails[2].indexof(":")+1, $headerdetails[2].Length - $headerdetails[2].indexof(":")-1 )
                           $headerdetails[3]= $headerdetails[3].Substring($headerdetails[3].indexof(":")+1, $headerdetails[3].Length - $headerdetails[3].indexof(":")-1 )
                           $headerdetails[4]= $headerdetails[4].Substring($headerdetails[4].indexof(":")+1, $headerdetails[4].Length - $headerdetails[4].indexof(":")-1 )
                           $headerdetails[5]= $headerdetails[5].Substring($headerdetails[5].indexof(":")+1, $headerdetails[5].Length - $headerdetails[5].indexof(":")-1 )
                           $headerdetails[6]= $headerdetails[6].Substring($headerdetails[6].indexof(":")+1, $headerdetails[6].Length - $headerdetails[6].indexof(":")-1 )
                           $headerdetails[7]= $headerdetails[7].Substring($headerdetails[7].indexof(":")+1, $headerdetails[7].Length - $headerdetails[7].indexof(":")-1 )
                           $headerdetails[8]= $headerdetails[8].Substring($headerdetails[8].indexof(":")+1, $headerdetails[8].Length - $headerdetails[8].indexof(":")-1 )
                           $headerdetails[9]= $headerdetails[9].Substring($headerdetails[9].indexof(":")+1, $headerdetails[9].Length - $headerdetails[9].indexof(":")-1 )
                       
                            

                        #write host "this file-"$headerdetails[2].Trim()"-check"


                        if( ($headerdetails[0] -ne "nothing") -and ($headerdetails[8].Trim() -eq "nothing") )
                        {

                         # get-Event "Error -$($headerdetails[8].Trim())-"
                          get-Event  "Writting header information from $($bkupfile.inputobject) to database"

                         $insertquery = "INSERT INTO [DBLOGDR].[dbo].[BackupHeaders]
                           ([FileName]
                           ,[DBName]
                           ,[SQLServerName]
                           ,[FirstLSN]
                           ,[LastLSN]
                           ,[CheckPointLSN]
                           ,[DatabaseBackupLSN]
                           ,[NativeBackupSize]
                           ,[DBSize]
                           ,[BackupType]
                           ,[Tool]
                           ,foldername)
                           select 
                           '$($bkupfile.inputobject)',           -- filename
                           ltrim('$($headerdetails[0].Trim())'), -- DBNAME
                           ltrim('$($headerdetails[1].Trim())'), --SQLServer
                           ltrim('$($headerdetails[2])'), --first lsn
                           ltrim('$($headerdetails[3])'), --last lsn
                           ltrim('$($headerdetails[4])'), --checkpointlsn
                           ltrim('$($headerdetails[5])'), --databasebackuplsn
                           ltrim('$($headerdetails[6].Trim())'), --nativedbsize
                           ltrim('$($headerdetails[7].Trim())'), --dbsize
                           ltrim('$($headerdetails[9].Trim())'), --backuptype
                            '$script:backuptool' ,                --toolid
                            '$folder'
                           "
                            try
                            {
                                #get-Event $insertquery
                                Invoke-SQLCMD -Query "$insertquery" -ServerInstance $script:drserver  -Database "DBLOGDR" -verbose
                            }
                            catch [Net.WebException]
                            {
                                
                                get-Event $_.Exception.ToString()
                            }
                        }
                        else
                        {
                            get-Event "$($bkupfile.inputobject)  Is either invalid or still being copied, skipping to next file. Error Code " $($headerdetails[8].Trim())
                        }

                        
                       # reinitiate headerdetails for next file
                        $headerdetails= @("nothing","nothing","nothing","nothing","nothing","nothing","nothing","nothing","nothing","nothing")

                       #for($h=0;$headerdetails.count-1; $h++)
                       #{
                       #     #reset values in array
                       #     get-Event $h
                       #     $headerdetails[$h] = "nothing"
                        #}
               
                    }
                
              }




   if ($script:backuptool -eq "SQL")
    {
       
        foreach ($bkupfile in $filestoberead )
        {
                
                get-Event "Reading Header Information from $($bkupfile.Inputobject)"
          
                #$header = sqlbackupc.exe -I $script:DRSERVER -sql "restore sqbheaderonly from disk = '$folder\$($bkupfile.inputobject)' WITH PASSWORD = 'N0tBl4nk', SINGLERESULTSET"

                $server1 = New-Object     Microsoft.SqlServer.Management.Smo.Server($script:drserver)  

                $restore = New-Object  ("Microsoft.SqlServer.Management.Smo.Restore") #, Microsoft.SqlServer.SmoExtended, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91")
                
                $backupfilepath = $bkupfile.Inputobject

                # get-Event "File: $backupfilepath"

                $restore.Devices.AddDevice($backupfilepath, [Microsoft.SqlServer.Management.Smo.DeviceType]::File) 

                $header = $restore.ReadBackupHeader($server)
                
                
            
                




                get-Event  "Writting header information from $($bkupfile.inputobject) to database"

                         $insertquery = "INSERT INTO [DBLOGDR].[dbo].[BackupHeaders]
                           ([FileName]
                           ,[DBName]
                           ,[SQLServerName]
                           ,[FirstLSN]
                           ,[LastLSN]
                           ,[CheckPointLSN]
                           ,[DatabaseBackupLSN]
                           ,[NativeBackupSize]
                           --,[DBSize]
                           ,[BackupType]
                           ,[Tool]
                           ,foldername
                           ,BackupStart
                           ,backupend)
                           select 
                           '$($bkupfile.inputobject)',           -- filename
                           '$($header.Rows[0][9])', -- DBNAME
                           '$($header.Rows[0][8])', --SQLServer
                           '$($header.Rows[0][13])', --first lsn
                           '$($header.Rows[0][14])', --last lsn
                           '$($header.Rows[0][15])', --checkpointlsn
                           '$($header.Rows[0][16])', --databasebackuplsn
                           
                            '$($header.Rows[0][51])', --nativedbsize
                           '$($header.Rows[0][2])', --backuptype
                            '$($script:backuptool)' ,                --toolid
                            '$folder',
                            '$($header.Rows[0][17])', --Backup Start Time
                            '$($header.Rows[0][18])' -- Backup End Time
                           "
                            try
                            {
                                # get-Event $insertquery
                                Invoke-SQLCMD -Query "$insertquery" -ServerInstance $script:drserver  -Database "DBLOGDR" -verbose
                            }
                            catch [Net.WebException]
                            {
                                
                                get-Event $_.Exception.ToString()
                            }
                        
           }
                
      }
}

function main()
{

    cd c:

    $server=Set-connection $script:drserver

    get-Event "Connected to $server"

    $script:table = get-Data $server

    

    read-RedGateHeader

    

    
    

}

main


