
SET QUOTED_IDENTIFIER ON
GO
-- Create Table
CREATE TABLE [DBLog].[BlockingReport](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[tracestarttime] [datetime] NULL,
	[traceendtime] [datetime] NULL,
	[tracetime] [varchar](256) NULL,
	[blockingtransactions] [varchar](50) NULL,
	[reportxml] [xml] NULL,
	[status] [int] NULL
)
GO

SET QUOTED_IDENTIFIER ON
GO
-- Create primary key
ALTER TABLE [DBLog].[BlockingReport] ADD  CONSTRAINT [PK_BlockingReport] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)
GO


SET QUOTED_IDENTIFIER ON
GO
-- create default
ALTER TABLE [DBLog].[BlockingReport] ADD  CONSTRAINT [DF__BlockingR__statu__2B5F6B28]  DEFAULT ((0)) FOR [status]
GO

SET QUOTED_IDENTIFIER ON
GO
-- add misc value

if not exists (select 1 from [DBLog].[MiscProperties] where propertyname ='BlockingProcessThreshold')
INSERT [DBLog].[MiscProperties] ([PropertyName], [Propertyvalue]) VALUES (N'BlockingProcessThreshold', N'6')
GO


SET QUOTED_IDENTIFIER ON
GO
-- PROCEDURE 1
if exists (select * from sys.objects where object_id = object_id('[DBLog].[usp_setup_blockProcess_report]'))
drop proc [DBLog].[usp_setup_blockProcess_report]
GO


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


-- PROCEDURE 2
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from sys.objects where object_id = object_id('[DBLog].[usp_blockedProcessReportViewer]'))
drop proc [DBLog].[usp_blockedProcessReportViewer]
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [DBLog].[usp_blockedProcessReportViewer]
(
	@Source nvarchar(max),
	@Type varchar(10) = 'FILE' 
)

AS

SET NOCOUNT ON

-- Validate @Type
IF (@Type NOT IN ('FILE', 'TABLE', 'XMLFILE', 'XESESSION'))
	RAISERROR ('The @Type parameter must be ''FILE'', ''TABLE'' or ''XMLFILE''', 11, 1)

IF (@Source LIKE '%.trc' AND @Type <> 'FILE')
	RAISERROR ('Warning: You specified a .trc trace. You should also specify @Type = ''FILE''', 10, 1)

IF (@Source LIKE '%.xml' AND @Type <> 'XMLFILE')
	RAISERROR ('Warning: You specified a .xml trace. You should also specify @Type = ''XMLFILE''', 10, 1)

IF (@Type = 'XESESSION' AND NOT EXISTS (
	SELECT * 
	FROM sys.server_event_sessions es
	JOIN sys.server_event_session_targets est
		ON es.event_session_id = est.event_session_id
	WHERE est.name in ('event_file', 'ring_buffer')
	  AND es.name = @Source ) 
)
	RAISERROR ('Warning: The extended event session you supplied does not exist or does not have an "event_file" or "ring_buffer" target.', 10, 1);
		

CREATE TABLE #ReportsXML
(
	monitorloop nvarchar(100) NOT NULL,
	endTime datetime NULL,
	blocking_spid INT NOT NULL,
	blocking_ecid INT NOT NULL,
	blocked_spid INT NOT NULL,
	blocked_ecid INT NOT NULL,
	blocked_hierarchy_string as CAST(blocked_spid as varchar(20)) + '.' + CAST(blocked_ecid as varchar(20)) + '/',
	blocking_hierarchy_string as CAST(blocking_spid as varchar(20)) + '.' + CAST(blocking_ecid as varchar(20)) + '/',
	bpReportXml xml not null,
	primary key clustered (monitorloop, blocked_spid, blocked_ecid),
	unique nonclustered (monitorloop, blocking_spid, blocking_ecid, blocked_spid, blocked_ecid)
)

DECLARE @SQL NVARCHAR(max);
DECLARE @TableSource nvarchar(max);

-- define source for table
IF (@Type = 'TABLE')
BEGIN
	-- everything input by users get quoted
	SET @TableSource = ISNULL(QUOTENAME(PARSENAME(@Source,4)) + N'.', '')
		+ ISNULL(QUOTENAME(PARSENAME(@Source,3)) + N'.', '')
		+ ISNULL(QUOTENAME(PARSENAME(@Source,2)) + N'.', '')
		+ QUOTENAME(PARSENAME(@Source,1));
END

-- define source for trc file
IF (@Type = 'FILE')
BEGIN	
	SET @TableSource = N'sys.fn_trace_gettable(N' + QUOTENAME(@Source, '''') + ', -1)';
END

-- load table or file
IF (@Type IN ('TABLE', 'FILE' ))
BEGIN
	SET @SQL = N'		
		INSERT #ReportsXML(blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
			monitorloop,bpReportXml,endTime)
		SELECT blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
			COALESCE(monitorloop, CONVERT(nvarchar(100), endTime, 120), cast(newid() as nvarchar(100))),
			bpReportXml,EndTime
		FROM ' + @TableSource + N'
		CROSS APPLY (
			SELECT CAST(TextData as xml)
			) AS bpReports(bpReportXml)
		CROSS APPLY (
			SELECT 
				monitorloop = bpReportXml.value(''(//@monitorLoop)[1]'', ''nvarchar(100)''),
				blocked_spid = bpReportXml.value(''(/blocked-process-report/blocked-process/process/@spid)[1]'', ''int''),
				blocked_ecid = bpReportXml.value(''(/blocked-process-report/blocked-process/process/@ecid)[1]'', ''int''),
				blocking_spid = bpReportXml.value(''(/blocked-process-report/blocking-process/process/@spid)[1]'', ''int''),
				blocking_ecid = bpReportXml.value(''(/blocked-process-report/blocking-process/process/@ecid)[1]'', ''int'')
			) AS bpShredded
		WHERE EventClass = 137
		  AND blocking_spid is not null
		  AND blocked_spid is not null';
		
	EXEC (@SQL);

END 


IF (@Type = 'XESESSION')
BEGIN
	DECLARE @SessionType sysname;
	DECLARE @SessionId int;
	DECLARE @SessionTargetId int;
	DECLARE @FilenamePattern sysname;

	SELECT TOP ( 1 ) 
		@SessionType = est.name,
		@SessionId = est.event_session_id,
		@SessionTargetId = est.target_id
	FROM sys.server_event_sessions es
	JOIN sys.server_event_session_targets est
		ON es.event_session_id = est.event_session_id
	WHERE est.name in ('event_file', 'ring_buffer')
		AND es.name = @Source;

	IF (@SessionType = 'event_file')
	BEGIN
		 
		SELECT @filenamePattern = REPLACE( CAST([value] AS sysname), '.xel', '*xel' )
		FROM sys.server_event_session_fields
		WHERE event_session_id = @SessionId
		  AND [object_id] = @SessionTargetId
		  AND name = 'filename'

		IF (@filenamePattern not like '%xel')
			set @filenamePattern += '*xel';

		INSERT #ReportsXML(blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
			monitorloop,bpReportXml,endTime)
		SELECT blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
			COALESCE(monitorloop, CONVERT(nvarchar(100), eventDate, 120), cast(newid() as nvarchar(100))),
			bpReportXml,eventDate
		FROM sys.fn_xe_file_target_read_file ( @filenamePattern, null, null, null) 
			as event_file_value
		CROSS APPLY ( SELECT CAST(event_file_value.[event_data] as xml) ) 
			as event_file_value_xml ([xml])
		CROSS APPLY (
			SELECT 
				event_file_value_xml.[xml].value('(event/@timestamp)[1]', 'datetime') as eventDate,
				event_file_value_xml.[xml].query('//event/data/value/blocked-process-report') as bpReportXml	
		) as bpReports
		CROSS APPLY (
			SELECT 
				monitorloop = bpReportXml.value('(//@monitorLoop)[1]', 'nvarchar(100)'),
				blocked_spid = bpReportXml.value('(/blocked-process-report/blocked-process/process/@spid)[1]', 'int'),
				blocked_ecid = bpReportXml.value('(/blocked-process-report/blocked-process/process/@ecid)[1]', 'int'),
				blocking_spid = bpReportXml.value('(/blocked-process-report/blocking-process/process/@spid)[1]', 'int'),
				blocking_ecid = bpReportXml.value('(/blocked-process-report/blocking-process/process/@ecid)[1]', 'int')
			) AS bpShredded
		WHERE blocking_spid is not null
		  AND blocked_spid is not null;

	END

	ELSE IF (@SessionType = 'ring_buffer')
	BEGIN
		-- get data from ring buffer
		INSERT #ReportsXML(blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
			monitorloop,bpReportXml,endTime)
		SELECT blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
			COALESCE(monitorloop, CONVERT(nvarchar(100), bpReportEndTime, 120), cast(newid() as nvarchar(100))),
			bpReportXml,bpReportEndTime
		FROM sys.dm_xe_session_targets st
		JOIN sys.dm_xe_sessions s 
			ON s.address = st.event_session_address
		CROSS APPLY 
			( SELECT CAST(st.target_data AS XML) ) 
			AS TargetData ([xml])
		CROSS APPLY 
			TargetData.[xml].nodes('/RingBufferTarget/event[@name="blocked_process_report"]') 
			AS bpNodes(bpNode)
		CROSS APPLY 
			bpNode.nodes('./data[@name="blocked_process"]/value/blocked-process-report')
			AS bpReportXMLNodes(bpReportXMLNode)
		CROSS APPLY
			(
			  SELECT 
				bpReportXml = CAST(bpReportXMLNode.query('.') as xml),
				bpReportEndTime = bpNode.value('(./@timestamp)[1]', 'datetime'),
				monitorloop = bpReportXMLNode.value('(//@monitorLoop)[1]', 'nvarchar(100)'),
				blocked_spid = bpReportXMLNode.value('(./blocked-process/process/@spid)[1]', 'int'),
				blocked_ecid = bpReportXMLNode.value('(./blocked-process/process/@ecid)[1]', 'int'),
				blocking_spid = bpReportXMLNode.value('(./blocking-process/process/@spid)[1]', 'int'),
				blocking_ecid = bpReportXMLNode.value('(./blocking-process/process/@ecid)[1]', 'int')
			) AS bpShredded
		WHERE s.name = @Source
		OPTION (MAXDOP 1);
	END

END



IF (@Type = 'XMLFILE')
BEGIN
	CREATE TABLE #TraceXML (
		id int identity primary key,
		ReportXML xml NOT NULL	
	)
	
	SET @SQL = N'
		INSERT #TraceXML(ReportXML)
		SELECT col FROM OPENROWSET (
				BULK ' + QUOTENAME(@Source, '''') + N', SINGLE_BLOB
			) as xmldata(col)';

	EXEC (@SQL);
	
	CREATE PRIMARY XML INDEX PXML_TraceXML ON #TraceXML(ReportXML);

	WITH XMLNAMESPACES 
	(
		'http://tempuri.org/TracePersistence.xsd' AS MY
	),
	ShreddedWheat AS 
	(
		SELECT
			bpShredded.blocked_ecid,
			bpShredded.blocked_spid,
			bpShredded.blocking_ecid,
			bpShredded.blocking_spid,
			bpShredded.monitorloop,
			bpReports.bpReportXml,
			bpReports.bpReportEndTime
		FROM #TraceXML
		CROSS APPLY 
			ReportXML.nodes('/MY:TraceData/MY:Events/MY:Event[@name="Blocked process report"]')
			AS eventNodes(eventNode)
		CROSS APPLY 
			eventNode.nodes('./MY:Column[@name="EndTime"]')
			AS endTimeNodes(endTimeNode)
		CROSS APPLY
			eventNode.nodes('./MY:Column[@name="TextData"]')
			AS bpNodes(bpNode)
		CROSS APPLY (
			SELECT CAST(bpNode.value('(./text())[1]', 'nvarchar(max)') as xml),
				CAST(LEFT(endTimeNode.value('(./text())[1]', 'varchar(max)'), 19) as datetime)
		) AS bpReports(bpReportXml, bpReportEndTime)
		CROSS APPLY (
			SELECT 
				monitorloop = bpReportXml.value('(//@monitorLoop)[1]', 'nvarchar(100)'),
				blocked_spid = bpReportXml.value('(/blocked-process-report/blocked-process/process/@spid)[1]', 'int'),
				blocked_ecid = bpReportXml.value('(/blocked-process-report/blocked-process/process/@ecid)[1]', 'int'),
				blocking_spid = bpReportXml.value('(/blocked-process-report/blocking-process/process/@spid)[1]', 'int'),
				blocking_ecid = bpReportXml.value('(/blocked-process-report/blocking-process/process/@ecid)[1]', 'int')
		) AS bpShredded
	)
	INSERT #ReportsXML(blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
		monitorloop,bpReportXml,endTime)
	SELECT blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
		COALESCE(monitorloop, CONVERT(nvarchar(100), bpReportEndTime, 120), 'unknown'),
		bpReportXml,bpReportEndTime
	FROM ShreddedWheat;
	
	DROP TABLE #TraceXML

END

-- Organize and select blocked process reports
;WITH Blockheads AS
(
	SELECT blocking_spid, blocking_ecid, monitorloop, blocking_hierarchy_string
	FROM #ReportsXML
	EXCEPT
	SELECT blocked_spid, blocked_ecid, monitorloop, blocked_hierarchy_string
	FROM #ReportsXML
), 
Hierarchy AS
(
	SELECT monitorloop, blocking_spid as spid, blocking_ecid as ecid, 
		cast('/' + blocking_hierarchy_string as varchar(max)) as chain,
		0 as level
	FROM Blockheads
	
	UNION ALL
	
	SELECT irx.monitorloop, irx.blocked_spid, irx.blocked_ecid,
		cast(h.chain + irx.blocked_hierarchy_string as varchar(max)),
		h.level+1
	FROM #ReportsXML irx
	JOIN Hierarchy h
		ON irx.monitorloop = h.monitorloop
		AND irx.blocking_spid = h.spid
		AND irx.blocking_ecid = h.ecid
)
SELECT 
	ISNULL(CONVERT(nvarchar(30), irx.endTime, 120), 
		'Lead') as traceTime,
		REPLICATE('-> ', h.level)
	--SPACE(4 * h.level) 
		+ CAST(h.spid as varchar(20)) 
		+ CASE h.ecid 
			WHEN 0 THEN ''
			ELSE '(' + CAST(h.ecid as varchar(20)) + ')' 
		END AS blockingTree,
	irx.bpReportXml
from Hierarchy h
left join #ReportsXML irx
	on irx.monitorloop = h.monitorloop
	and irx.blocked_spid = h.spid
	and irx.blocked_ecid = h.ecid
order by h.monitorloop, h.chain

DROP TABLE #ReportsXML

GO




-- Procedure 3
if exists (select * from sys.objects where object_id = object_id('[DBLog].[usp_import_BlockingReport]'))
drop proc [DBLog].[usp_import_BlockingReport]
GO


SET QUOTED_IDENTIFIER ON
GO

CREATE proc [DBLog].[usp_import_BlockingReport] @pathout nvarchar(256) OUTPUT
as
SET NOCOUNT ON
declare @traceid int, @path nvarchar(256), @starttime datetime, @endtime datetime

select @traceid = id, @path = [path], @starttime=start_time, @endtime = getdate() from sys.traces where path like '%blockedProcessReport%'

--stop the trace and close the trace
if @traceid > 0
begin
	EXEC sp_trace_setstatus @traceid =@traceid, @status = 0; -- stop trace (assuming it's trace ID 2)
	EXEC sp_trace_setstatus @traceid =@traceid, @status = 2; -- close trace (assuming it's trace ID 2)

	declare @trace table
	(
	tracetime varchar(256),
	blockingtransactions varchar (50),
	reportxml XML
	)

	--read trace
	insert into @trace
	exec dblog.usp_blockedProcessReportViewer @path

	-- import trace into table
	insert into dblog.blockingreport (tracestarttime,traceendtime, tracetime, blockingtransactions, reportxml, [status])
	select @starttime, @endtime, tracetime, blockingtransactions, reportxml, 0 from @trace
	
	set @pathout = @path

end


GO






-- Procedure 4
if exists (select * from sys.objects where object_id = object_id('[DBLog].[usp_del_blockingReport_Trace]'))
drop proc [DBLog].[usp_del_blockingReport_Trace]
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE proc [DBLog].[usp_del_blockingReport_Trace] @filename nvarchar(256)
as
SET NOCOUNT ON
declare @sqltext nvarchar(500)
	if (select value from sys.configurations where name = 'show advanced options' )= 0
	exec sp_configure 'show advanced options',1

	exec sp_configure 'xp_cmdshell', 1
	reconfigure

set @sqltext = 'master.dbo.xp_cmdshell ''DEL "' + @filename + '."'''
EXEC(@sqltext)
GO








-- Procedure 5
if exists (select * from sys.objects where object_id = object_id('[DBLog].[usp_BlockProcess_WorkFlow]'))
drop proc [DBLog].[usp_BlockProcess_WorkFlow]
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE proc [DBLog].[usp_BlockProcess_WorkFlow] @status int
as
set nocount on
-- @status = 1 "Reset the trace into new file"
-- @status = 0 "Stop trace after importing"
declare @path nvarchar(256)

declare @version int
declare @productversion varchar(20)
select @productversion = cast(serverproperty('productversion') as varchar(20))


select @version= substring(@productversion,0,charindex('.',@productversion,0))

if (@version > 9)
begin
--Step 1:
-- Import existing trace and save the path into @path variable
exec dblog.usp_import_BlockingReport @pathout = @path OUTPUT

-- Step 2:
-- Setup new trace
EXEC [DBLog].[usp_setup_blockProcess_report]  @status

-- Step 3:
-- removed closed trace
exec dblog.usp_del_blockingReport_Trace @path 
end

else if (@version < 10)
begin
	print 'Version below 2008 not supported'
END
GO