#clear-host
# Please make sure Feature Pack SQL 2012 (SMO, CLR, PowershellTools) are installed for SQL 2008. For 2012 and up, please install the matching feature packs

#Input Parameters
 Param([Parameter(Mandatory=$true)][string]$drservername
 ,[Parameter(Mandatory=$true)][string]$dbname
 ,[Parameter(Mandatory=$true)][string]$sourceservername)


# Get Libraries

#load assemblies
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
#Need SmoExtended for backup
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null


 Add-Type -Path "C:\Program Files\Microsoft SQL Server\110\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
add-type -path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\11.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll”
Add-Type -Assembly 'Microsoft.SqlServer.BatchParser, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91'
$env:PSModulePath = $env:PSModulePath + ";C:\Program Files\Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS"
#Add-PSSnapin SqlServerCmdletSnapin100
#Add-PSSnapin SqlServerProviderSnapin100
import-module sqlps







#  
# Loads the SQL Server Management Objects (SMO)  
#  

$ErrorActionPreference = "Stop"  

$sqlpsreg="HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.SqlServer.Management.PowerShell.sqlps110"  

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
cd $sqlpsPath  
#update-FormatData -prependpath SQLProvider.Format.ps1xml   
Pop-Location  


# End Loading














# $drservername = 'LAAN4DRXSQL01'
# $script:dbname = 'AnnuityTransactions'
# $sourceservername = 'AN3PRODSQL01'

$script:dbname = $dbname
$script:sqlserver = $drservername



$script:dbobj = "" #storing object

$script:id = ""
$script:filepath = ""
$script:tool = ""
$script:backuptype = ""

$script:datafileloc = ""
$script:logfileloc = ""


$query="declare @last_lsn_ID_log bigint
declare @last_lsn_ID_full bigint
declare @lsn numeric(38,0)
declare @lastLsnFull numeric(38,0)
declare @lastLsnLog numeric(38,0)
declare @id bigint
declare @srvname varchar(50) = '$sourceservername' 
declare @dbname varchar(50) = '$script:dbname' 




if exists(select 1 from backupheaders where sqlservername =@srvname and dbname = @dbname and restoreprogress = 'inprogress' /*and tool = @backuptool*/)
begin
	print 'Restore in progres, quiting'
    
	set @id = 0
	return
end

if exists(select 1 from backupheaders where sqlservername =@srvname and dbname = @dbname and restoreprogress = 'failed' /*and tool = @backuptool*/)
begin
	print 'Previous restore failed, please fix previous restore before proceeding'
	set @id = 0
	return
end



select @last_lsn_ID_log = ID from backupheaders where backuptypecomp = 'TLOG'
and restoreend =(select max(restoreend) from backupheaders where backuptypecomp = 'TLOG' and sqlservername =@srvname and dbname = @dbname /*and tool = @backuptool*/)  
and sqlservername =@srvname and dbname = @dbname

if (@last_lsn_ID_log is null)
begin
	Print 'No Previous Log Restores found, looking for Last Full Restores'
	
	select @last_lsn_ID_full = ID from backupheaders where backuptypecomp = 'FULL'
	and restoreend =(select max(restoreend) from backupheaders where backuptypecomp = 'FULL' 
    and sqlservername =@srvname and dbname = @dbname  /*and tool = @backuptool*/) and sqlservername =@srvname and dbname = @dbname and FirstLSN <> lastlsn /* and tool = @backuptool*/

	if (@last_lsn_ID_full is null)
	begin
		PRINT 'Not initialized yet, Initializing now'
		
		select @id=id from backupheaders where backuptypecomp = 'FULL' and lastlsn = (select max(lastlsn) from backupheaders where backuptypecomp = 'FULL' 
        and sqlservername =@srvname and dbname = @dbname  /*and tool = @backuptool*/) and sqlservername =@srvname and dbname = @dbname  /*and tool = @backuptool*/
		--select @id [BackupID] ,'Full backup needs to be restored'
		--select *from backupheaders where id = @last_lsn_ID_full
	end	
	else if (@last_lsn_id_full is not null)
	begin
		select @lastLsnFull = lastlsn from backupheaders where id = @last_lsn_id_full
		--select * from backupheaders where id = @last_lsn_id_full
		select @id = id from backupheaders  where @lastlsnfull+1 between firstlsn and lastlsn and sqlservername =@srvname and dbname = @dbname /*and tool = @backuptool */
		--select *from backupheaders where @lastlsnfull+1 between firstlsn and lastlsn
		--select @id [BackupID], 'First Log backup needs to be restored'
	end
		
end
else if (@last_lsn_ID_log is not null)
begin
	
	select @id=id from backupheaders where firstlsn in (select lastlsn from backupheaders where id = @last_lsn_ID_log and sqlservername =@srvname and dbname = @dbname  
    /*and tool = @backuptool*/) and sqlservername =@srvname and dbname = @dbname /*and tool = @backuptool*/ and FirstLSN <> lastlsn
	--select @id [BackupID], 'Next Log backup needs to be restored'
end

select ID, FolderName + '\' + Filename [FilePath] , SQLServerName, DBNAME, TOOL, BACKUPTYPECOMP  from backupheaders where id = @id"





function Get-DefaultLocations()
{
    #Get the default locations

    $srv = new-object ('Microsoft.SqlServer.Management.Smo.Server') $script:sqlserver 
	$srv.ConnectionContext.StatementTimeout = 0
    $script:datafileloc = $srv.Settings.DefaultFile
    $script:logfileloc = $srv.Settings.DefaultLog
    
    # if Default locations are not available
    
    if($script:datafileloc.length -eq 0)
    {
        $script:datafileloc = $server.Information.MasterDBPath    
    } 

    if($script:logfileloc.length -eq 0)
    {
        $script:logfileloc = $server.Information.MasterDBLogPath    
    } 

	# add database name to file location
	$script:datafileloc = $script:datafileloc  + "\" + $script:dbname
	$script:logfileloc = $script:logfileloc  + "\" + $script:dbname
	
    # write-host $script:datafileloc
    # write-host $script:logfileloc

	#data file	
	if((Test-Path $script:datafileloc) -eq 0)
	{
		mkdir $script:datafileloc;
	}
	
	#log file
		#data file
	
	if((Test-Path $script:logfileloc) -eq 0)
	{
		mkdir $script:logfileloc;
	}
}





function Set-connection($machine)
{
    try
    {
        $smo = New-Object ('Microsoft.SQLServer.Management.smo.server') $machine
	$smo.ConnectionContext.StatementTimeout = 0
        #$smo
        
    }
    
    catch
    {
        get-event "Error Establishing connection to  $machine"
        get-Event $_.Exception.Message
    }

    return $smo
}

function update-DRStatus($srv, $bid, $message, $errormsg)
{

    #write-host $script:dbname
    $script:dbobj = $srv.Databases.Item("DBLOGDR")

    $message = $message.replace("'","*")
    $errormsg = $errormsg.replace("'","*")

    #write-host "DatabaseOBject"
    #write-host $script:dbobj

    #if ($message -eq "inprogress")
    #{
    #    $script = "update backupheaders set restorestart=getdate() , lastupdated = getdate() , restoreprogress = '$message', details = '$errormsg' where id = $bid"
    #}
    #elseif ($message -eq "completed")
    #{
    #    $script = "update backupheaders set restoreend=getdate() , lastupdated=getdate() , restoreprogress = '$message', details = '$errormsg' where id = $bid"
    #}
    #else
    #{
    #    $script = "update backupheaders set restoreend=getdate() , lastupdated = getdate() , details = '$message', restoreprogress = 'failed' where id = $bid"

    #}
    $script = "update backupheaders set restoreend=getdate() , lastupdated = getdate() , details = '$errormsg', restoreprogress = '$message' where id = $bid; update backupheaders set restorestart=getdate() where restorestart is null and id = $bid;"

    write-host $script
    $script:dbobj.ExecuteNonQuery($script)
}



function exit-if-in-progress($srv)
{
    #select 1 from backupheaders where sqlservername =@srvname and dbname = @dbname and restoreprogress = 'inprogress'
    $dbinprog = $srv.Databases.Item("DBLOGDR")
    $ds = $dbinprog.ExecuteWithResults("select 1 from backupheaders where sqlservername ='$sourceservername' and dbname = '$script:dbname' and restoreprogress = 'inprogress'")
    
        Foreach ($t in $ds.Tables)
        {
           $rowcount = $t.Rows.Count

           if ($rowcount -gt 0)
           {
                write-host "Restore in progress on $sourceservername for $script:dbname, quitting"
                exit;
            }
        }

}

function exit-if-in-fail($srv)
{
    #select 1 from backupheaders where sqlservername =@srvname and dbname = @dbname and restoreprogress = 'inprogress'
    $dbinprog = $srv.Databases.Item("DBLOGDR")

    $ds = $dbinprog.ExecuteWithResults("select * from backupheaders where sqlservername ='$sourceservername' and dbname = '$script:dbname' and restoreprogress = 'failed'")
    
        Foreach ($t in $ds.Tables)
        {
           $rowcount = $t.Rows.Count

           if ($rowcount -gt 0)
           {
                write-host "Previous failures found on $sourceservername for $script:dbname, quitting"
                exit;
            }
        }

}

function get-Data($srv)
{
    
        $script:dbobj = $srv.Databases.Item("DBLOGDR")

        #write-host $query

        $ds = $script:dbobj.ExecuteWithResults($query)
        Foreach ($t in $ds.Tables)
        {
           $rowcount = $t.Rows.Count

           if ($rowcount -gt 1)
           {
                write-host "More than one backup found"
                return;
           }
           if ($rowcount -lt 1)
           {
                write-host "No backup found"
                return;
           }
           else
           {
                write-host $t.rows[0][19]
                $script:id = $t.rows[0]["ID"]
                $script:filepath = $t.rows[0]["filepath"]
                $script:tool = $t.rows[0]["Tool"]   
                $script:dbname = $t.rows[0]["dbname"]    
                $script:backuptype = $t.rows[0]["BACKUPTYPECOMP"]       
            }
        }
}


function Restore-Database()
{

    

    if($script:tool -eq "SQL")
    {

        $srv = new-object ('Microsoft.SqlServer.Management.Smo.Server') $script:sqlserver 
	$srv.ConnectionContext.StatementTimeout = 0

        $bdi = new-object ('Microsoft.SqlServer.Management.Smo.BackupDeviceItem') ($script:filepath, 'File') # $script:filepath
        $rs = New-Object ('Microsoft.SqlServer.Management.Smo.Restore') 

        $rs.Database = $script:dbname 
 
                
        $rs.Devices.Add($bdi) 

       try
       {

            $fl = $rs.ReadFileList($srv)
        }
        catch [Exception]
        {
            write-host "Failed to read files list " + $_.Exception.Message
           
        }

        
    
        $rfl = @()
        $movecommand = ''
        # new-object('Microsoft.SqlServer.Management.Smo.RelocateFile') 

        foreach ($fil in $fl) { 
 
        $rsfile = new-object('Microsoft.SqlServer.Management.Smo.RelocateFile') 
       
 
        $rsfile.LogicalFileName = $fil.LogicalName 
 
        if ($fil.Type -eq 'D') { 
 
            $rsfile.PhysicalFileName = $script:datafileloc + "\" + (Split-Path -Leaf $fil.PhysicalName )
 
            } 
 
        else { 
 
            $rsfile.PhysicalFileName = $script:logfileloc + "\" +  (Split-Path -Leaf $fil.physicalname)
         
 
            } 
 
        # Check if db folder does not exists

        $rfl += $rsfile 
        $movecommand += "move '$($rsfile.logicalfilename.ToString())' to '$($rsfile.physicalfilename.ToString())',"
 
        } 

        
 
        # $backupfilepath

        # write-host $dbname

        #$dbname
        

        write-host "Restoring [$script:dbname]"
        try
        {
            


            update-DRStatus $con $script:id "inprogress" ""

            if ($script:backuptype -eq "FULL")
            {
                
                # Write-Host "Restore-SqlDatabase -ServerInstance $drservername -Database $script:dbname -BackupFile $script:filepath -RelocateFile $rfl -NoRecovery"
                 # Restore-SqlDatabase -ServerInstance $drservername -Database $script:dbname -BackupFile $script:filepath -RelocateFile $rfl -NoRecovery -ConnectionTimeout 0

		# adding inputobject
		#Write-Host "Restore-SqlDatabase -ServerInstance $drservername -Database $script:dbname -BackupFile $script:filepath -RelocateFile $rfl -NoRecovery"
   
                     $restorescript= "restore database   $script:dbname   from disk =  '$script:filepath'  with  $movecommand  norecovery, replace"
                     write-host $restorescript


                 #Restore-SqlDatabase -InputObject [Microsoft.SqlServer.Management.Smo.Server]$srv -Database $script:dbname -BackupFile $script:filepath -RelocateFile @($rfl) -NoRecovery -ConnectionTimeout 0
                 invoke-sqlcmd -ServerInstance $script:sqlserver -Database "Master" -query $restorescript -QueryTimeout 0
                
            }
            if ($script:backuptype -eq "TLOG")
            {
               $restorelogscript = "restore log $script:dbname from disk = '$script:filepath' with norecovery"
               invoke-sqlcmd -ServerInstance $script:sqlserver -Database "Master" -query $restorelogscript -QueryTimeout 0
                # Restore-SqlDatabase -ServerInstance $drservername -Database $script:dbname -BackupFile $script:filepath -RestoreAction Log -NoRecovery -ConnectionTimeout 0
		#Restore-SqlDatabase -InputObject $srv -Database $script:dbname -BackupFile $script:filepath -RestoreAction Log -NoRecovery -ConnectionTimeout 0
            }
            write-host $errorcode
            update-DRStatus $con $script:id "completed" ""
            cd c:\dblog # get out of the SQL PS drive
        }
        catch [Exception]
        {
            write-host "Failed to restore "
            write-host $_.Exception|format-list -force
            update-DRStatus $con $script:id  $_.Exception.Message ""
        }
        # write-host $script
    }

    if($script:tool -eq "RGT")
    {
        $con = Set-connection $drservername
        try
        {
            write-host "Restoring [$script:dbname]"
            
            update-DRStatus $con $script:id "inprogress" ""
           if ($script:backuptype -eq "FULL")
            {
                 $query = "Restore Database [$script:dbname] from DISK='$script:filepath' WITH PASSWORD = 'N0tBl4nk', MOVE DATAFILES TO '$script:datafileloc', MOVE LOGFILES TO '$script:logfileloc', NORECOVERY"
                             
            }
            if($script:backuptype -eq "TLOG")
            {
                $query = "RESTORE LOG [$script:dbname] FROM DISK = '$script:filepath' WITH PASSWORD='N0tBl4nk', NORECOVERY"
            }
            #write-host $query 
            #Invoke-SQLCMD -Query "$query" -ServerInstance "$drservername"  -Database "master" -verbose  
            
            write-host "Server Name"$drservername

           $errorcode = sqlbackupc.exe -I $drservername -sql $query -debug

           if($errorcode -like '*abnormally*' -or $errorcode -like '*error*')
           {
           update-DRStatus $con $script:id "failed" $errorcode
           }
           else
           {
            update-DRStatus $con $script:id "completed" $errorcode
            }
        }
        catch [Exception]
        {
            update-DRStatus $con $script:id  "failed" $_.Exception.Message
            write-host $_.Exception|format-list -force
        }
    }
}



function main()
{
    Get-DefaultLocations

    $con = Set-connection $drservername

   #if previously failed restore then exit
    exit-if-in-fail $con

    #if other restore in progress then exit
    exit-if-in-progress $con

    get-Data $con



    Restore-Database

}


main;