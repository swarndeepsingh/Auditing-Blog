function Load-Modules
{
#Add SMO
Add-Type -Path "C:\Program Files (x86)\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"

 [Reflection.Assembly]::LoadFile(([System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo").location))


# Add PS
$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\Microsoft SQL Server\100\Tools\PowerShell\Modules\SQLPS;C:\Windows\System32\WindowsPowerShell\v1.0\Modules"
# Import-Module sqlps

Add-PSSnapin SqlServerProviderSnapin100
add-pssnapin SqlServerCmdletSnapin100



}
Load-Modules


# Remove-PSDrive P



    $sqlserver = ".\sql2k8"
    $rootfolderitems = Get-ChildItem -LIteralPath "C:\swarn\backup"


# New-PSDrive -Name P -PSProvider FileSystem -Root $rootfolder

# Get list and database information from header



foreach ($bkupfile in Get-ChildItem  $rootfolder | Select-Object basename)
{


    # Go to each file one by one in for each loop
    # $backupfilepath = 'P:\' + $bkupfile.BaseName + '.bak'

    $server = New-Object     Microsoft.SqlServer.Management.Smo.Server($sqlserver)  
    $restore = New-Object     Microsoft.SqlServer.Management.Smo.Restore 

    $backupfilepath = $rootfolder + $bkupfile.BaseName + '.bak'

    $restore.Devices.AddDevice($backupfilepath, [Microsoft.SqlServer.Management.Smo.DeviceType]::File) 

    $header = $restore.ReadBackupHeader($server)

    if ($header.Rows.Count -eq 1)
    {
        $dbname = $header.Rows[0]["DatabaseName"]
    }

    #Get the default locations

    $srv = new-object ('Microsoft.SqlServer.Management.Smo.Server') $sqlserver 


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
	$datafileloc = $datafileloc + "\" + $dbname
	$logfileloc = $logfileloc + "\" + $dbname
	
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


    $rs = new-object('Microsoft.SqlServer.Management.Smo.Restore') 

    $rs.Database = $dbname 
 
    $rs.Devices.Add($bdi) 


    $fl = $rs.ReadFileList($srv) 


    $rfl = @()

    foreach ($fil in $fl) { 
 
    $rsfile = new-object('Microsoft.SqlServer.Management.Smo.RelocateFile') 
 
    $rsfile.LogicalFileName = $fil.LogicalName 
 
    if ($fil.Type -eq 'D') { 
 
        $rsfile.PhysicalFileName = $datafileloc + "" + (Split-Path -Leaf $fil.PhysicalName )
 
        } 
 
    else { 
 
        $rsfile.PhysicalFileName = $logfileloc + "" +  (Split-Path -Leaf $fil.physicalname)
         
 
        } 
 
 	# Check if db folder does not exists

    $rfl += $rsfile 
 
    } 

    $rfl
 
  # $backupfilepath

  # write-host "Restoring $dbname"
  Restore-SqlDatabase -ServerInstance $sqlserver -Database $dbname -BackupFile $backupfilepath -RelocateFile $rfl -NoRecovery
  # write-host $script



}





