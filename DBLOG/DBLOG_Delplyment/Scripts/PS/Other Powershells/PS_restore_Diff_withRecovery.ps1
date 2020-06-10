
# declare global variables
$script:sqlserver = ""
$script:rootfolderitems = ""


# clear-host

remove-item -Path function:Load-Modules

function Load-Modules
{
#  
# Loads the SQL Server Management Objects (SMO)  
#  
  
$ErrorActionPreference = "Continue"  
  
$sqlpsreg="HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.SqlServer.Management.PowerShell.sqlps120"  
  
if (Get-ChildItem $sqlpsreg -ErrorAction "SilentlyContinue")  
{  
    throw "SQL Server Provider for Windows PowerShell is not installed."  
}  
else  
{  
    $item = Get-ItemProperty $sqlpsreg  
    $sqlpsPath = [System.IO.Path]::GetDirectoryName($item.Path)  
}  
  
$assemblylist =   
"Microsoft.SqlServer.Management.Common",  
"Microsoft.SqlServer.Smo",  
"Microsoft.SqlServer.Dmf ",  
"Microsoft.SqlServer.Instapi ",  
"Microsoft.SqlServer.SqlWmiManagement ",  
"Microsoft.SqlServer.ConnectionInfo ",  
"Microsoft.SqlServer.SmoExtended ",  
"Microsoft.SqlServer.SqlTDiagM ",  
"Microsoft.SqlServer.SString ",  
"Microsoft.SqlServer.Management.RegisteredServers ",  
"Microsoft.SqlServer.Management.Sdk.Sfc ",  
"Microsoft.SqlServer.SqlEnum ",  
"Microsoft.SqlServer.RegSvrEnum ",  
"Microsoft.SqlServer.WmiEnum ",  
"Microsoft.SqlServer.ServiceBrokerEnum ",  
"Microsoft.SqlServer.ConnectionInfoExtended ",  
"Microsoft.SqlServer.Management.Collector ",  
"Microsoft.SqlServer.Management.CollectorEnum",  
"Microsoft.SqlServer.Management.Dac",  
"Microsoft.SqlServer.Management.DacEnum",  
"Microsoft.SqlServer.Management.Utility"  
  
foreach ($asm in $assemblylist)  
    {  
        $asm = [Reflection.Assembly]::LoadWithPartialName($asm)  
    }  
  
Push-Location  
# cd $sqlpsPath  
update-FormatData -prependpath SQLProvider.Format.ps1xml   
Pop-Location 



}

function Load-SMO
{
    Add-Type -Path "C:\Program Files (x86)\Microsoft SQL Server\120\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"

}

 [AppDomain]::CurrentDomain.GetAssemblies().GetTypes() | ? FullName -eq Microsoft.SqlServer.Management.Smo.RelocateFile | select Assembly
 [AppDomain]::CurrentDomain.GetAssemblies().GetTypes() | ? FullName -eq Microsoft.SqlServer.Management.Smo.Restore | select Assembly

Load-Modules
Load-SMO

 # clear-host
# Remove-PSDrive P

function GetParameters
{
    $script:sqlserver = read-host "Enter the Server Name and Instance:"
    $script:rootfolderitems = read-host "Enter the Path where the backups are copied. (The folder should not have any subdirectories):"
}


   # $script:sqlserver = "SMYWFXSTGSQC01\INS2"
   # $script:rootfolderitems =  "J:\ECHOES\"

   GetParameters




   write-host "Connecting to $script:sqlserver"
   write-host "Backups location $script:rootfolderitems"

# New-PSDrive -Name P -PSProvider FileSystem -Root $rootfolder

# Get list and database information from header



if ($script:sqlserver -ne "")
{
    if ($script:rootfolderitems -ne "")
    {

            foreach ($bkupfile in Get-ChildItem  $script:rootfolderitems | Select-Object basename)
            {

                # Go to each file one by one in for each loop
                # $backupfilepath = 'P:\' + $bkupfile.BaseName + '.bak'

                $server = New-Object     Microsoft.SqlServer.Management.Smo.Server($script:sqlserver)  
    
    

                $restore = New-Object  ("Microsoft.SqlServer.Management.Smo.Restore") #, Microsoft.SqlServer.SmoExtended, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91")


                $backupfilepath = $script:rootfolderitems + $bkupfile.BaseName + '.bak'

                write-host $backupfilepath

                # Write-host "File: $backupfilepath"

                $restore.Devices.AddDevice($backupfilepath, [Microsoft.SqlServer.Management.Smo.DeviceType]::File) 

                $header = $restore.ReadBackupHeader($server)

                if ($header.Rows.Count -eq 1)
                {
                    $dbname = $header.Rows[0]["DatabaseName"]
                }

                #Get the default locations

                $srv = new-object ('Microsoft.SqlServer.Management.Smo.Server') $script:sqlserver 


                $datafileloc = $srv.Settings.DefaultFile
                $logfileloc = $srv.Settings.DefaultLog
    
                # if Default locations are not available
    
                if($datafileloc.length -eq 0)
                {
                    $datafileloc = $server.Information.MasterDBPath    
                } 

                if($logfileloc.length -eq 0)
                {
                    $logfileloc = $server.Information.MasterDBLogPath    
                } 

	            # add database name to file location
	            $datafileloc = $datafileloc  + $dbname
	            $logfileloc = $logfileloc  + $dbname
	
                write-host $datafileloc
                write-host $logfileloc

	            #data file	
	            if((Test-Path $datafileloc) -eq 0)
	            {
		            mkdir $datafileloc;
	            }
	
	            #log file
		            #data file
	
	            if((Test-Path $logfileloc) -eq 0)
	            {
		            mkdir $logfileloc;
	            }

   

                #read file list


                $bdi = new-object ('Microsoft.SqlServer.Management.Smo.BackupDeviceItem') ($backupfilepath, 'File')


                # $rs = new-object('Microsoft.SqlServer.Management.Smo.Restore') 
                $rs = New-Object ("Microsoft.SqlServer.Management.Smo.Restore") #, Microsoft.SqlServer.SmoExtended, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" 

                $rs.Database = $dbname 
 
                
                $rs.Devices.Add($bdi) 


                $fl = $rs.ReadFileList($srv) 
    
                $rfl = @()

                foreach ($fil in $fl) { 
 
                $rsfile = new-object('Microsoft.SqlServer.Management.Smo.RelocateFile') 
 
                $rsfile.LogicalFileName = $fil.LogicalName 
 
                if ($fil.Type -eq 'D') { 
 
                    $rsfile.PhysicalFileName = $datafileloc + "\" + (Split-Path -Leaf $fil.PhysicalName )
 
                    } 
 
                else { 
 
                    $rsfile.PhysicalFileName = $logfileloc + "\" +  (Split-Path -Leaf $fil.physicalname)
         
 
                    } 
 
 	            # Check if db folder does not exists

                $rfl += $rsfile 
 
                } 

                $rfl
 
              # $backupfilepath

              # write-host $dbname

             $dbname


              write-host "Restoring $dbname"
              # Restore-SqlDatabase -ServerInstance $script:sqlserver -Database $dbname -BackupFile $backupfilepath -RelocateFile $rfl -NoRecovery

              Restore-SqlDatabase -ServerInstance $script:sqlserver -Database $dbname -BackupFile $backupfilepath  #-RestoreAction Database

              # write-host $script



            }
        }
    }





