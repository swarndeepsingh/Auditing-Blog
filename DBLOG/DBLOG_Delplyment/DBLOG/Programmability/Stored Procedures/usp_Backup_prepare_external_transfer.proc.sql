CREATE proc [DBLog].[usp_Backup_prepare_external_transfer]
as
declare @backupJobId int, @backupID int, @sourcepath varchar(8000), @destinationpath varchar(8000)
declare @sourcepathID int, @destinationPathID int, @cmd varchar(8000), @DBName varchar(8000)
declare cursorConfig cursor for
select a.Backup_Job_ID, a.backup_id, a.[FileName] from DBLog.Backup_jobs a with (NOLOCK)
where a.filename_mirror = 'External Queued' and Backup_Job_ID not in
(select backup_job_id from DBLog.Backup_transfer_Job with (NOLOCK))
OPEN cursorConfig
fetch next from cursorConfig into @backupJobId, @backupID, @sourcepath
	while @@FETCH_STATUS = 0
	BEGIN
		select @destinationPathID=
		MirrorLocationID from dblog.backup_info with (NOLOCK)
		where Backup_ID = @backupID
		
		
		select @sourcepathID=
		backuplocationid , @DBName = DBName from dblog.backup_info with (NOLOCK)
		where Backup_ID = @backupID
		
		-- Replacing the sourcepath with the location path of that location id
		--select  @sourcepath = LocationPath from DBLog.Location_Details with (NOLOCK)
		--where LocationID = @sourcepathID
				
		-- Replacing the destinatiop with location path of that location ID
		select  @destinationpath = LocationPath from DBLog.Location_Details with (NOLOCK)
		where LocationID =@destinationPathID
		 
		-- Create directory if does not exists  
		set @destinationpath = @destinationpath + '\' + @DBName
		-- set @MirrorLocation = @MirrorLocation + '\' + @dbname


		set @cmd = 'IF NOT EXIST ' + @destinationpath + ' MKDIR ' + @destinationpath 
		EXEC xp_cmdshell @cmd

		-- set @cmd = 'IF NOT EXIST ' + @MirrorLocation  + ' MKDIR ' + @MirrorLocation 
		-- EXEC xp_cmdshell @cmd
		-- end creating directory

		
		insert into DBLog.Backup_transfer_Job (Backup_Job_ID, Backup_ID,[Source],Destination,Status, sourcelocationid, destinationlocationid)
		select @backupJobId,@backupID,@sourcepath,@destinationpath,'Pending', @sourcepathID,@destinationPathID
		
		select  @destinationpath = @destinationpath + substring(@sourcepath,
		len(@sourcepath)-charindex('\',REVERSE(@sourcepath))+1,LEN(@sourcepath)) 
		from dblog.backup_info with (NOLOCK)
		where Backup_ID = @backupID
		
		update DBLog.Backup_jobs
		set filename_mirror = @destinationpath
		where backup_job_id = @backupJobId
		
		fetch next from cursorConfig into @backupJobId, @backupID, @sourcepath
	END
CLOSE cursorConfig
Deallocate cursorConfig