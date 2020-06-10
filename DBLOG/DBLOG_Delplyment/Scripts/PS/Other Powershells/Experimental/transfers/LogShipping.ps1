#clear-host

#Input Parameters
# Param([Parameter(Mandatory=$true)][string]$drservername
# ,[Parameter(Mandatory=$true)][string]$dbname
# ,[Parameter][string]$metadatasql)


$drservername = 'LAAN4DRXSQL01'
$script:dbname = 'AnnuityTransactions'
$sourceservername = 'AN3PRODSQL01'


$script:dbobj = "" #storing object

$script:id = ""
$script:filepath = ""
$script:tool = ""

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


select @last_lsn_ID_log = ID from backupheaders where backuptypecomp = 'TLOG'
and restoreend =(select max(restoreend) from backupheaders where backuptypecomp = 'TLOG' and sqlservername =@srvname and dbname = @dbname /*and tool = @backuptool*/)  
and sqlservername =@srvname and dbname = @dbname

if (@last_lsn_ID_log is null)
begin
	Print 'No Previous Log Restores found, looking for Last Full Restores'
	
	select @last_lsn_ID_full = ID from backupheaders where backuptypecomp = 'FULL'
	and restoreend =(select max(restoreend) from backupheaders where backuptypecomp = 'FULL' 
    and sqlservername =@srvname and dbname = @dbname  /*and tool = @backuptool*/) and sqlservername =@srvname and dbname = @dbname  /* and tool = @backuptool*/

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
    /*and tool = @backuptool*/) and sqlservername =@srvname and dbname = @dbname /*and tool = @backuptool*/
	--select @id [BackupID], 'Next Log backup needs to be restored'
end

select ID, FolderName + '\' + Filename [FilePath] , SQLServerName, DBNAME, TOOL  from backupheaders where id = @id"

Add-Type -Path "C:\Program Files\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
Add-Type -Assembly 'Microsoft.SqlServer.BatchParser, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91'

$script:sqlserver = $drservername



function Get-DefaultLocations()
{
    #Get the default locations

    $srv = new-object ('Microsoft.SqlServer.Management.Smo.Server') $script:sqlserver 
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
	$script:datafileloc = $script:datafileloc  + $script:dbname
	$script:logfileloc = $script:logfileloc  + $script:dbname
	
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
        $smo = New-Object Microsoft.SQLServer.Management.smo.server($machine) 
        #$smo
        
    }
    
    catch
    {
        get-event "Error Establishing connection to  $machine"
        get-Event $_.Exception.Message
    }

    return $smo
}

function update-DRStatus($srv, $bid, $message)
{
    #write-host $script:dbname
    $script:dbobj = $srv.Databases.Item("DBLOGDR")

    #write-host "DatabaseOBject"
    #write-host $script:dbobj

    if ($message -eq "inprogress")
    {
        $script = "update backupheaders set restorestart=getdate() , lastupdated = getdate() , restoreprogress = '$message' where id = $bid"
    }
    elseif ($message -eq "completed")
    {
        $script = "update backupheaders set restoreend=getdate() , lastupdated=getdate() , restoreprogress = '$message' where id = $bid"
    }
    else
    {
        $script = "update backupheaders set restoreend=getdate() , lastupdated = getdate() , restoreprogress = '$message' where id = $bid"
    }
    write-host $script
    $script:dbobj.ExecuteNonQuery($script)
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
           else
           {
                $script:id = $t.rows[0]["ID"]
                $script:filepath = $t.rows[0]["filepath"]
                $script:tool = $t.rows[0]["Tool"]   
                $script:dbname = $t.rows[0]["dbname"]             
            }
        }
}


function Restore-Database()
{
    if($script:tool -eq "SQL")
    {

        $bdi = new-object ('Microsoft.SqlServer.Management.Smo.BackupDeviceItem') ($backupfilepath, 'File')
        $rs = New-Object ("Microsoft.SqlServer.Management.Smo.Restore") 

        $rs.Database = $script:dbname 
 
                
        $rs.Devices.Add($bdi) 


        $fl = $rs.ReadFileList($srv) 
    
        $rfl = @()

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
 
        } 

        $rfl
 
        # $backupfilepath

        # write-host $dbname

        #$dbname


        write-host "Restoring [$script:dbname]"
        Restore-SqlDatabase -ServerInstance $drservername -Database $script:dbname -BackupFile $script:filepath -RelocateFile $rfl -NoRecovery
        # write-host $script
    }

    if($script:tool -eq "RGT")
    {
        $con = Set-connection $drservername
        try
        {
            write-host "Restoring [$script:dbname]"
            
            update-DRStatus $con $script:id "inprogress"
            #"EXECUTE         Master..sqlbackup 'Restore Database [$dbname]  from DISK = ''$file''           WITH PASSWORD = ''$pwd'',      MOVE DATAFILES TO ''$datafilepath'',       MOVE LOGFILES TO ''$logfilepath'''"
            #$query = "EXECUTE Master..sqlbackup 'Restore Database [$script:dbname] from DISK=''$script:filepath'' WITH PASSWORD=''NotBl4nk'', MOVE DATAFILES TO ''$script:datafileloc'', MOVE LOGFILES TO ''$script:logfileloc'''"
            $query = "Restore Database [$script:dbname] from DISK='$script:filepath' WITH PASSWORD='NotBl4nk', MOVE DATAFILES TO '$script:datafileloc', MOVE LOGFILES TO '$script:logfileloc'"

            write-host $query 
            #Invoke-SQLCMD -Query "$query" -ServerInstance "$drservername"  -Database "master" -verbose  
            
            write-host "Server Name"$drservername

           sqlbackupc.exe -I $drservername -sql $query -debug

            update-DRStatus $con $script:id "completed"
        }
        catch [Exception]
        {
            update-DRStatus $con $script:id  $_.Exception.Message
        }
    }
}



function main()
{
    Get-DefaultLocations

    $con = Set-connection $drservername

    get-Data $con

    Restore-Database

}


main;