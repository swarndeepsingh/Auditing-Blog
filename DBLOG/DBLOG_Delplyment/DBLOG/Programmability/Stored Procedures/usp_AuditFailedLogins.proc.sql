CREATE PROC [DBLog].[usp_AuditFailedLogins] @action varchar(20), @folder nvarchar(4000), @tracenm varchar(255)
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
set @on = 1
set @maxsize = 500
set @dtime = GETDATE()+10
--set @tracefoldername = N'D:\tracefile\login_trace\' + @file 
if SUBSTRING(@folder, len(@folder),1) <> '\'
begin
	set @folder = @folder + '\'
end
set @tracefoldername =@folder + @file 



	
if @action = 'Reset'
Begin
	----- Stop Existing Trace -----
	set @msg = 'Stopping Trace for trace named ' + @tracenm
	raiserror(@msg, 10,1)
	
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

	EXEC sp_trace_setevent @traceID, 20, 1, @on

	EXEC sp_trace_setevent @traceID, 20, 6, @on

	EXEC sp_trace_setevent @traceID, 20, 8, @on

	EXEC sp_trace_setevent @traceID, 20, 14, @on


	EXEC sp_trace_setevent @traceID, 20, 15, @on

	EXEC sp_trace_setevent @traceID, 20, 23, @on

	EXEC sp_trace_setevent @traceID, 20, 26, @on

	EXEC sp_trace_setevent @traceID, 20, 35, @on

	EXEC sp_trace_setevent @traceID, 20, 64, @on

	EXEC sp_trace_setevent @traceID, 20, 11, @on

	EXEC sp_trace_setevent @traceID, 20, 6, @on

	-- Set Filters here
	--exec sp_trace_setfilter  @traceid , 34, 1, 6, N'%usp_CV_CreateDocumentStubEntry%'


	--Start Trace
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

	
END


if @action = 'Stop'
Begin
	set @msg = 'Stop trace requested for ' + @tracenm
	raiserror(@msg, 10,1)
	exec [DBLOG].usp_StopTrace @tracenm
End


-- clean cache folders

--EXEC usp_Cleanup_Traces @tracenm