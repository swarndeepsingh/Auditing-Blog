CREATE  PROC [DBLog].[usp_AuditTSQL] @action varchar(20), @folder nvarchar(4000), @tracenm varchar(255)
as

/*
-- This SP will enable server side tracing for failed login audits
-- @action accepts two values - 'Reset' or 'Stop'
--		'Reset' will create a new trace and imports the previous trace
--		'Stop' will stop the trace and imports the previous trace if exists
-- @folder containts the folder name where the trace file needs to be stored
-- @tracenm contains the name of trace
*/

set nocount on 

declare @dtime datetime
declare @out int, @tracerowid int
declare @traceid int, @tracefoldername nvarchar(500), @tracename varchar(255), @file nvarchar(4000), @traceidold int
declare @rowid int, @file_full nvarchar(4000), @rwcount int, @msg varchar(2000)
set @tracename = @tracenm
set @file=CONVERT(nvarchar(128),serverproperty('ServerName')) + '_' + @tracename + '_' +  replace(replace(replace(convert(varchar(23), getdate(),126),':',''),'-',''),'.','') 
--if it is named instance then rename the servername correctly by replacing '\' with '-'

set @file = replace(@file, '\','_')


declare @maxsize bigint, @on bit
declare @columnnumber int, @logicaloperator int, @comparisonoperator int, @columnvalue nvarchar(256)
set @on = 1
set @maxsize = 500
select @dtime = GETDATE()+10
--set @tracefoldername = N'D:\tracefile\login_trace\' + @file 
if SUBSTRING(@folder, len(@folder),1) <> '\'
begin
	set @folder = @folder + '\'
end
set @tracefoldername =@folder + @file 





--------------------------------

if @action = 'Reset'
Begin
	set @msg = 'Stopping trace for ' + @tracenm
	raiserror(@msg, 10,1)
	----- Stop Existing Trace -----
	Exec [DBLOG].usp_StopTrace @tracenm

	set @msg = 'Returned back to main SP for ' + @tracenm
	raiserror(@msg, 10,1)
	-- Set Trace Below
	exec @out = sp_trace_create  @traceid OUTPUT,
				@options = 2,  
				@tracefile=@tracefoldername,
				 @maxfilesize=@maxsize, 
				@stoptime=@dtime/*,
				 @filecount=50 */
				 
	set @msg = 'Setting up new trace for ' + @tracenm
	raiserror(@msg, 10,1)

	if @out <> 0
	begin
		raiserror (N'Error Number %d',15,1,@out)
		return
	end

	print 'New Trace Created, Trace ID # ' + cast(@traceid as varchar(10))

	-- Reference: http://msdn.microsoft.com/en-us/library/ms186265.aspx

	EXEC sp_trace_setevent @traceID, 41, 1, @on

	EXEC sp_trace_setevent @traceID, 41, 6, @on

	EXEC sp_trace_setevent @traceID, 41, 8, @on

	EXEC sp_trace_setevent @traceID, 41, 14, @on


	EXEC sp_trace_setevent @traceID, 41, 15, @on

	EXEC sp_trace_setevent @traceID, 41, 23, @on

	EXEC sp_trace_setevent @traceID, 41, 26, @on

	EXEC sp_trace_setevent @traceID, 41, 35, @on

	EXEC sp_trace_setevent @traceID, 41, 64, @on

	EXEC sp_trace_setevent @traceID, 41, 11, @on

	EXEC sp_trace_setevent @traceID, 41, 6, @on

	EXEC sp_trace_setevent @traceID, 41, 10, @on





-- SP Tracing 43
	EXEC sp_trace_setevent @traceID, 43, 1, @on

	EXEC sp_trace_setevent @traceID, 43, 6, @on

	EXEC sp_trace_setevent @traceID, 43, 8, @on

	EXEC sp_trace_setevent @traceID, 43, 14, @on

	EXEC sp_trace_setevent @traceID, 43, 15, @on

	EXEC sp_trace_setevent @traceID, 43, 23, @on

	EXEC sp_trace_setevent @traceID, 43, 26, @on

	EXEC sp_trace_setevent @traceID, 43, 35, @on

	EXEC sp_trace_setevent @traceID, 43, 64, @on

	EXEC sp_trace_setevent @traceID, 43, 11, @on

	EXEC sp_trace_setevent @traceID, 43, 6, @on

	EXEC sp_trace_setevent @traceID, 41, 10, @on

	-- Set Filters here
	


	--	Following cursor will add filter for user account names
	declare @accountnm nvarchar(256)
	Declare AddFilter CURSOR for
	select accountname from [DBLOG].auditable_logins
	OPEN AddFilter

	Fetch NEXT from AddFilter
	INTO @accountnm

	WHILE @@FETCH_STATUS = 0
	BEGIN
		exec sp_trace_setfilter  @traceid , 11, 1, 6, @accountnm
		
		Fetch NEXT from AddFilter
	INTO @accountnm
		END
	CLOSE AddFilter
	Deallocate AddFilter


	-- Following filters will add exceptions to trace. These are other than account names

	
	Declare AddExceptionFilters CURSOR for
	select columnnumber, logicaloperator, comparisonoperator, columnvalue from [DBLOG].Trace_Exceptions with (NOLOCK) where tracename = @tracename
	OPEN AddExceptionFilters

	Fetch NEXT from AddExceptionFilters
	INTO @columnnumber , @logicaloperator , @comparisonoperator , @columnvalue 

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- reference http://msdn.microsoft.com/en-us/library/ms174404.aspx
		exec sp_trace_setfilter  @traceid , @columnnumber, @logicaloperator, @comparisonoperator, @columnvalue
		
		Fetch NEXT from AddExceptionFilters
		INTO @columnnumber , @logicaloperator , @comparisonoperator , @columnvalue
		END
	CLOSE AddExceptionFilters
	Deallocate AddExceptionFilters

	
	-- Additional Filters
	exec sp_trace_setfilter  @traceid , 35, 0, 1, N'master'
	exec sp_trace_setfilter  @traceid , 35, 0, 1, N'msdb'
--	exec sp_trace_setfilter  @traceid , 11, 1, 6, N'%SSINGH%'
	
	set @msg = 'Enabling new trace for ' + @tracenm
	raiserror(@msg, 10,1)
	exec @out = sp_trace_setstatus @TraceID, 1

	if @out <> 0
	begin
		raiserror (N'Error Number %d',15,1,@out)
		--Stop the trace here
		exec sp_trace_setstatus  @traceid, 0 

		--Delete the trace here
		exec sp_trace_setstatus   @traceid, 2 
		return
	end
	Else
	Begin
		print 'Trace Enabled. Trace ID # ' + cast(@traceid as varchar(10))
		insert into [DBLOG].Trace_Info (Tracename,TraceID,TraceFile,ServerName,CreateDate,Active)
		select @tracename, @traceid, @tracefoldername + '.trc', CONVERT(nvarchar(128),serverproperty('ServerName')), GETDATE(),1
		
		update [DBLOG].trace_properties
		set propertyvalue = GETDATE()
		where tracename = @tracename and propertyname = 'LastImported'
		
	END


	
	
End

if @action = 'Stop'
Begin
	set @msg = 'Trace Stop has been requested for  ' + @tracenm
	raiserror(@msg, 10,1)
	exec [DBLOG].usp_StopTrace @tracenm
End

-- clean cache folders

--EXEC usp_Cleanup_Traces @tracenm