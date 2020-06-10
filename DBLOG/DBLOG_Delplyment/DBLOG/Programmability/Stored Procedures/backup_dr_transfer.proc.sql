CREATE proc [DBLog].[backup_dr_transfer] @backup_id int, @return int OUTPUT
as    
set NOCOUNT ON    
declare @backupname varchar(255), @dbname varchar(100), @backuplocation varchar(8000), @enabled char(1),    
@drtransfer char(1), @filename varchar(8000), @backuptype varchar(100), @sql nvarchar(4000), @fullfilename varchar(8000)    
,@backup_job_id int, @result varchar(8000), @error int, @MirrorLocation varchar(8000), @MirrorFileName varchar(8000), @localRetention int, @remoteRetention int, @UseInternalMirrorFunction char(1)  
, @compression char(1), @backuplocationid int, @mirrorlocationid int, @errortext varchar(200), @cmd varchar(8000)  


-- Following variables are used in RedGate only    
DECLARE @exitcode int
DECLARE @sqlerrorcode int
---------------------------------------------


select @backupname=backupname, @dbname=dbname, @backuplocation=backuplocation    
, @enabled=[enabled],@drtransfer=dr_transfer, @backuptype = backuptype, @MirrorLocation = MirrorLocation  , @localRetention = localretention_days, @remoteRetention = RemoteRetention_days, @UseInternalMirrorFunction = UseInternalMirrorFunction  
, @compression = CompressBackup  
, @backuplocationid = BackupLocationID  
, @mirrorlocationid = MirrorLocationID  
from dblog.backup_info with (NOLOCK)    
where backup_id = @backup_id  and Enabled=1  
  

  declare @backupTool varchar(100)

  select @backupTool = ISNULL(a.backupToolName,'Native') from DBLOG.Backup_Tools a  
  join dblog.Backup_info b
	on a.backupToolID = b.BackupToolID
	where b.Backup_ID = @backup_id


select @backupTool = ISNULL(@backuptool, 'Native')

exec [dblog].[usp_MapLocation] @backuplocationid, @backuplocation output  
  
  
  
if (@mirrorlocationid is not null  and @drtransfer =1)
 exec [dblog].[usp_MapLocation] @mirrorlocationid, @MirrorLocation output  
  
if @backupname is null  
begin  
return  
--The backup is disabled thus exiting.  
end  
  
  
-- Create directory if does not exists    
set @backuplocation = @backuplocation + '\' + @dbname  
set @MirrorLocation = @MirrorLocation + '\' + @dbname  
  
  
set @cmd = 'IF NOT EXIST "' + @backuplocation + '" MKDIR "' + @backuplocation   +'"'
EXEC xp_cmdshell @cmd  
  
set @cmd = 'IF NOT EXIST "' + @MirrorLocation  + '" MKDIR "' + @MirrorLocation  + '"' 
EXEC xp_cmdshell @cmd  
-- end creating directory  
  
set @filename = replace(@@servername, '\', '$') + '_' + case @backupTool when 'Native' then '_' when 'RedGate' then 'RedGate_' when 'Litespeed' then 'Litespeed_' end + @backupname + '_' + replace(convert(varchar(8), GETDATE(), 112)+convert(varchar(8), GETDATE(), 114), ':','') + case when @backuptype = 'D' then '.dmp' when @backuptype ='I' then  '.bak' else '.trn' end    
      
set @fullfilename = @backuplocation + '\' + @filename    
set @MirrorFileName = @MirrorLocation + '\' + @filename  
  
  
 set @MirrorFileName = case @drtransfer when 1 then 'External Queued'   else 'No Remote backup' end  
 -- set @MirrorFileName = case @MirrorLocation when Null then 'No Remote backup' end
 select 'Mirror Location - ', @mirrorlocation
 
 
 if @backupTool = 'Native' 
 begin
			-- Get Text for Native SQL Backup
			exec dblog.usp_Backup_SQL_Native @backupType = @backuptype, @dbname =@dbname, @fullfilename = @fullfilename,
				@compression = @compression, @filename =@filename, @sqlout = @sql output
	
 
			-- set @sql = N'Backup ' + case @backuptype when 'D' then 'Database' when 'I' then 'Database' else 'Log' end    
			-- + ' [' + @dbname + '] To DISK=''' + @fullfilename +  ''' WITH '+ case @backuptype   
			-- when 'I' then 'DIFFERENTIAL, ' else ' ' end     
			--  + 'FORMAT,  SKIP, REWIND, NOUNLOAD,'   
			-- + case @compression when 1 then 'COMPRESSION,' else ' ' end +  
			--  '  NAME= ''' + @filename +''''    
			---- end  
			insert into dblog.backup_jobs (backup_id, backup_start_time, backup_end_time, [filename], [status],[FileName_Mirror])    
			values (@backup_id,getdate(),NULL,@fullfilename,'Started',@MirrorFileName)    
  
			set @backup_job_id = @@IDENTITY    
  
			begin try  

  
			 exec(@sql)    
			 exec [dblog].usp_Backup_prepare_external_transfer  
			END TRY  
  
			BEGIN CATCH  
			 set @error = @@ERROR   
			 update dblog.backup_jobs    
			 set backup_end_time = GETDATE()    
			 ,status = 'Failed: Error ' +CAST(@error as varchar(20))  + ':' + isnull(ERROR_MESSAGE(),'')  
			 where backup_job_id = @backup_job_id    






   
			 set @errortext=  'Backup ID ' + cast(@backup_job_id as varchar(10)) + ' failed. Error ID: ' + CAST(@error as varchar(50)) +  ' - ' + isnull(ERROR_MESSAGE(),'')  
   
			 raiserror (@errortext, 10, 1 )  
   
   
			 GOTO EXITING  
			END CATCH  
  
end
  

if @backupTool ='Redgate'
begin

	
	exec dblog.usp_Backup_SQL_RedGate @backupType = @backuptype, @dbname =@dbname, 
	 @fullfilename = @fullfilename,
	 @filename =@filename, @sqlout = @sql output

	insert into dblog.backup_jobs (backup_id, backup_start_time, backup_end_time, [filename], [status],[FileName_Mirror])    
	 values (@backup_id,getdate(),NULL,@fullfilename,'Started',@MirrorFileName)    
  
	set @backup_job_id = @@IDENTITY    


	

	begin try  
		exec master..sqlbackup @sql, @exitcode OUTPUT, @sqlerrorcode OUTPUT
	End Try

	begin catch
		set @error = @@ERROR   
			 update dblog.backup_jobs    
			 set backup_end_time = GETDATE()    
			 ,status = 'Failed: Error ' +CAST(@error as varchar(20))  + ':' + isnull(ERROR_MESSAGE(),'')  
			 where backup_job_id = @backup_job_id    

			 set @errortext=  'Backup ID ' + cast(@backup_job_id as varchar(10)) + ' failed. Error ID: ' + CAST(@error as varchar(50)) +  ' - ' + isnull(ERROR_MESSAGE(),'')  
   
			 raiserror (@errortext, 10, 1 )  
   
   
			 GOTO EXITING  

	end catch
	IF (@exitcode <>0) OR (@sqlerrorcode <> 0)
		BEGIN
			update dblog.backup_jobs    
			 set backup_end_time = GETDATE()    
			 ,status = 'Failed: Error ' +CAST(@error as varchar(20))  + ':' + isnull(ERROR_MESSAGE(),'')  
			 where backup_job_id = @backup_job_id    
   
			 set @errortext=  'Backup ID(RedGate) ' + cast(@backup_job_id as varchar(10)) + ' failed with exitcode: ' + CAST(@exitcode as varchar(50)) +  ', SQL Error Code: ' + CAST(@sqlerrorcode as varchar(50));  
   
			 raiserror (@errortext, 16, 1 )  
			GOTO EXITING
		  
		END
		
	exec [dblog].usp_Backup_prepare_external_transfer  

end
   



if @backupTool = 'Litespeed' 
 begin
			-- Get Text for Native SQL Backup
			exec dblog.usp_Backup_SQL_Litespeed @backupType = @backuptype, @dbname =@dbname, @fullfilename = @fullfilename,
				@compression = @compression, @filename =@filename, @sqlout = @sql output
	
 
			
			insert into dblog.backup_jobs (backup_id, backup_start_time, backup_end_time, [filename], [status],[FileName_Mirror])    
			values (@backup_id,getdate(),NULL,@fullfilename,'Started',@MirrorFileName)    
  
			set @backup_job_id = @@IDENTITY    
  
			begin try  

  
			 exec(@sql)    
			 exec [dblog].usp_Backup_prepare_external_transfer  
			END TRY  
  
			BEGIN CATCH  
			 set @error = @@ERROR   
			 update dblog.backup_jobs    
			 set backup_end_time = GETDATE()    
			 ,status = 'Failed: Error ' +CAST(@error as varchar(20))  + ':' + isnull(ERROR_MESSAGE(),'')  
			 where backup_job_id = @backup_job_id    






   
			 set @errortext=  'Backup ID ' + cast(@backup_job_id as varchar(10)) + ' failed. Error ID: ' + CAST(@error as varchar(50)) +  ' - ' + isnull(ERROR_MESSAGE(),'')  
   
			 raiserror (@errortext, 10, 1 )  
   
   
			 GOTO EXITING  
			END CATCH  
  
end
   


    
--if @error =0    
--begin    
 update dblog.backup_jobs    
 set backup_end_time = GETDATE()    
 , status = 'Completed', retainUntil_local = DATEADD(DD,@localretention,getdate())  
 , retainUntil_remote = DATEADD (DD,@RemoteRetention,getdate())  
 where backup_job_id = @backup_job_id    
  
  
 update c  
set c.backupsizeKB = isnull(a.compressed_backup_size, a.backup_size)  
from  msdb.dbo.backupset a with (NOLOCK)  
join msdb.dbo.backupmediafamily b with (NOLOCK)  
 on a.media_set_id = b.media_set_id  
join DBLog.Backup_Jobs c with (NOLOCK)  
 on c.FileName = b.physical_device_name  
where c.backupsizeKB is null  
and c.backup_job_id = @backup_job_id  
  
  
  
  
EXITING:  
exec [dblog].[usp_DeleteMapLocation] @backuplocationid  
  
if (@mirrorlocationid is not null  and @drtransfer =1)
 exec [dblog].[usp_DeleteMapLocation] @mirrorlocationid  
  
set @return = @backup_job_id  