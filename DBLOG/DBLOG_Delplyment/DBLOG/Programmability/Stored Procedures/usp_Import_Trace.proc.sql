CREATE proc [DBLog].[usp_Import_Trace]
as

declare @tracelocation varchar(2000), @rowid int, @rwcount int, @tracename varchar(255), @err int
----- Import Trace Data
	Declare Import_Trace CURSOR for
	select tracefile, tracename from trace_info with (NOLOCK)where Active = 0 and Archived = 0
	
	OPEN Import_Trace

	Fetch NEXT from Import_Trace
	INTO @tracelocation, @tracename

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		
		select @rowid = rowid from [DBLOG].Trace_Info with (NOLOCK)
		where TraceFile = @tracelocation
		
		if @rowid is null 
		 set @rowid = 0
		
		if @tracename = 'AuditTSQL'
		begin
			print 'Importing Trace - ' + @tracelocation
			INSERT INTO [DBLOG].Trace_AuditTSQL_Archive
			select @rowid, cast(TextData as varchar(8000)), HostName, SPID, StartTime, Success, ServerName, DatabaseName,  NTUserName, Loginname, ApplicationName, EndTime
			from ::fn_trace_gettable (@tracelocation ,DEFAULT)
			where cast(TextData as varchar(8000)) is not null
			set @rwcount = @@ROWCOUNT
			
			set @err = @@ERROR
			if @err <> 0 GOTO Error
			

			print 'Number of Rows Imported from Trace File - ' + cast(@rwcount as varchar(10))
			print 'Completed Import - ' + @tracelocation

			update trace_info
			set archived = 1, rowsimported = @rwcount where rowid = @rowid
		end
		
		if @tracename = 'AuditFailedLogin'
		begin
			INSERT INTO [DBLOG].Trace_Failed_Login_Archive
			select @rowid, cast(TextData as varchar(8000)), HostName, SPID, StartTime, Success, ServerName, DatabaseName,  NTUserName, Loginname
			from ::fn_trace_gettable (@tracelocation ,DEFAULT)
			where cast(TextData as varchar(8000)) is not null
			set @rwcount = @@ROWCOUNT
			set @err = @@ERROR
			if @err <> 0 GOTO Error


			print 'Number of Rows Imported from Trace File - ' + cast(@rwcount as varchar(10))
			print 'Completed Import - ' + @tracelocation

			update [DBLOG].trace_info
			set archived = 1, rowsimported = @rwcount where rowid = @rowid
		end

	Fetch NEXT from Import_Trace
	INTO @tracelocation, @tracename
		END
	CLOSE Import_Trace
	Deallocate Import_Trace
return
ERROR:
			update [DBLOG].trace_info
			set archived = -1, rowsimported = -1 where rowid = @rowid