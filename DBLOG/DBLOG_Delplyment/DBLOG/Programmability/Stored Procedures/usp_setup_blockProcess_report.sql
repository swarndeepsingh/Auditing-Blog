SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [DBLog].[usp_setup_blockProcess_report]  @status int
as
SET NOCOUNT ON

-- @status = 1 "Continue"
-- @status = 0 "Stop"

-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
declare @threshold int
--declare @DateTime datetime

select @threshold = propertyvalue from dblog.MiscProperties where PropertyName = 'BlockingProcessThreshold' 

if (@status = 1) -- continue
begin
	declare @defaultpath nvarchar(256)
	declare @advoption bit, @blockthreshold bit

	select @defaultpath = substring(filename, 1, len(filename)-charindex('\',reverse(filename),1)) from sys.sysfiles where fileid = 1

	select @defaultpath = @defaultpath + '\blockedProcessReport' + cast(year(getdate()) as varchar) + cast(month(getdate()) as varchar) +cast(day(getdate()) as varchar) +cast(datepart(hour,getdate()) as varchar) + cast(datepart(minute, getdate()) as varchar)+ cast(datepart(second, getdate()) as varchar)



	if (select value from sys.configurations where name = 'show advanced options' )= 0
	exec sp_configure 'show advanced options',1

	exec sp_configure 'blocked process threshold (s)', @threshold
	reconfigure


	--set @DateTime = DATEADD(mi,10,getdate()); /* Run for five minutes */
	set @maxfilesize = 100


	-----------Set my filename here:
	exec @rc = sp_trace_create @TraceID output, 0, @defaultpath , @maxfilesize--, @Datetime
	if (@rc != 0) goto error


	-- Set the events
	declare @on bit
	set @on = 1
	exec sp_trace_setevent @TraceID, 137, 1, @on
	exec sp_trace_setevent @TraceID, 137, 12, @on

	-- Set the Filters
	declare @intfilter int
	declare @bigintfilter bigint
 
	-- Set the trace status to start
	exec sp_trace_setstatus @TraceID, 1
 
	-- display trace id for future references
	--select TraceID=@TraceID
	goto finish


	error:
	select 'Error',ErrorCode=@rc
 
	finish:
	print 'Completed'
END
GO