cls

Add-Type -Path "C:\Program Files\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
Add-Type -Assembly 'Microsoft.SqlServer.BatchParser, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91'



Import-Module SQLPS

 $folder = "\\an3prodsql01b\Backups\AN3PRODSQL01\AnnuityTransactions"
 $backuptype = "Full"
 $script:backuptool = "RGT"
 $script:drserver = "LAAN4DRXSQL01"
 $script:extention = ""
 $headerdetails= @("nothing","nothing","nothing","nothing","nothing","nothing","nothing","nothing","nothing","nothing")
 $script:filename=@()
 $script:db = ""
 $script:table=@()



 function Set-connection($drmachine)
{
    try
    {
        $smo = New-Object Microsoft.SQLServer.Management.smo.server($drmachine) 
        #$smo
        
    }
    
    catch
    {
        print-host-error "Error Establishing connection to " $machine
        write-host $_.Exception.Message
    }

    return $smo
}


function get-Data($srv)
{
        $script:db = $srv.Databases.Item("DBLOGDR")

        #$script:db

        #write-host $srv
        $sql = "Select filename from backupheaders"
        $result = $script:db.ExecuteWithResults($sql)
        #$result
        $table=$result.Tables[0]

        return $table
}






function set-BackupType()
{
     if ($backuptype -eq "Full")
     {
        $script:extention="dmp"
     }
     elseif ($backuptype -eq "Differential")
     {
        $script:extention="bak"
     }
     elseif ($backuptype -eq "Log")
     {
        $script:extention="trn"
     }
 }


 function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}

#$drivearray=@(ls function:[d-z]: -n|?{!(test-path $_)})
#$sourcemapdrive = $drivearray[$drivearray.length-1]
    
function read-RedGateHeader()
{  
    #write-host $script:filename
    
    $fileitems = Get-ChildItem  $folder\* -include *.trn | select-object name | Sort-Object name
    $tablefiles = $script:table.filename


 
    #write-host $tablefiles

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
                
                write-host "Reading Header Information from "  $bkupfile.Inputobject
          
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

                         # write-host "Error -$($headerdetails[8].Trim())-"
                          write-host  "Writting header information from " $($bkupfile.inputobject) " to database"

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
                           ,[Tool])
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
                            '$script:backuptool'                 --toolid
                           "
                            try
                            {
                                #write-host $insertquery
                                Invoke-SQLCMD -Query "$insertquery" -ServerInstance $script:drserver  -Database "DBLOGDR" -verbose
                            }
                            catch [Net.WebException]
                            {
                                
                                write-host $_.Exception.ToString()
                            }
                        }
                        else
                        {
                            write-host $bkupfile.inputobject " Is either invalid or still being copied, skipping to next file. Error Code " $($headerdetails[8].Trim())
                        }

                        
                       # reinitiate headerdetails for next file
                        $headerdetails= @("nothing","nothing","nothing","nothing","nothing","nothing","nothing","nothing","nothing","nothing")

                       #for($h=0;$headerdetails.count-1; $h++)
                       #{
                       #     #reset values in array
                       #     write-host $h
                       #     $headerdetails[$h] = "nothing"
                        #}
               
                    }
                
              }
}

function main()
{

    cd c:
    set-BackupType

    $server=Set-connection $script:drserver

    write-host Connected to $server

    $script:table = get-Data $server

    




    set-BackupType

    read-RedGateHeader

    

    
    

}

main


