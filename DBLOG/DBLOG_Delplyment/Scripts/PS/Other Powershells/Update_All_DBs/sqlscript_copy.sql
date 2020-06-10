use DBLOG
GO
CREATE TABLE [DBLog].[requests](
	[CaptureDataID] [bigint] IDENTITY(1,1) NOT NULL,
	[session_id] [smallint] NOT NULL,
	[request_id] [int] NULL,
	[command] [nvarchar](32) NOT NULL,
	[start_time] [datetime] NOT NULL,
	[status] [nvarchar](30) NOT NULL,
	[sql_handle] [varbinary](64) NULL,
	[plan_handle] [varbinary](64) NULL,
	[object_id] [int] NULL,
	[wait_time] [int] NOT NULL,
	[wait_type] [nvarchar](60) NULL,
	[wait_resource] [nvarchar](256) NOT NULL,
	[last_wait_type] [nvarchar](60) NOT NULL,
	[cpu_time] [int] NOT NULL,
	[total_elapsed_time] [int] NOT NULL,
	[reads] [bigint] NOT NULL,
	[writes] [bigint] NOT NULL,
	[text] [nvarchar](max) NULL,
	[query_plan] [xml] NULL,
	[databasename] [nvarchar](128) NOT NULL,
	[logical_reads] [bigint] NULL,
	[ClientIP] [varchar](15) NULL,
	[MemoryMB] [numeric](18, 2) NULL,
	[TempDBMB] [numeric](18, 2) NULL,
	[Statement_StartOffSet] [int] NULL,
	[Statement_EndOffSet] [int] NULL,
	[ServerName] [nvarchar](128) NULL,
	[collectiondate] [datetime] NOT NULL,
	[ExportStatus] [int] NOT NULL CONSTRAINT [DF_requests_ExportStatus]  DEFAULT ((0)),
 CONSTRAINT [PK_requests] PRIMARY KEY CLUSTERED 
(
	[CaptureDataID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO






use DBLOG
GO
create  procedure dblog.usp_GetRequests
as
declare @requests TABLE (
	[session_id] [smallint] NOT NULL,
	[request_id] int null,
	[command] [nvarchar](32) NOT NULL,
	[start_time] [datetime] NOT NULL,
	[status] [nvarchar](30) NOT NULL,
	[sql_handle] [varbinary](64) NULL,
	[plan_handle] [varbinary](64) NULL,
	[object_id] int  null,
	[wait_time] [int] NOT NULL,
	[wait_type] [nvarchar](60) NULL,
	[wait_resource] [nvarchar](256) NOT NULL,
	[last_wait_type] [nvarchar](60) NOT NULL,
	[cpu_time] [int] NOT NULL,
	[total_elapsed_time] [int] NOT NULL,
	[reads] [bigint] NOT NULL,
	[writes] [bigint] NOT NULL,
	[text] [nvarchar](max) NULL,
	[query_plan] [xml] NULL,
	[databasename] [nvarchar](128) NOT NULL,
	[logical_reads] [bigint] NOT NULL,
	/*added new*/
	[ClientIP] [varchar](15) NULL,
	[MemoryMB] numeric(20,2) NULL,
	[TempDBMB] Numeric(20,2) null,
	[startoffset] int null,
	[endoffset] int null,
	/**/
	[ServerName] [nvarchar](128) NULL
	
)

insert into @requests
select 
req.session_id, 
req.request_id,
req.command, 
req.start_time, 
req.status,
req.sql_handle, 
req.plan_handle, 
dest.objectid,
req.wait_time, 
req.wait_type, 
req.wait_resource, 
req.last_wait_type,
req.cpu_time, 
req.total_elapsed_time, 
req.reads, 
req.writes,
dest.text, 
isnull(cast(deqp.query_plan as varchar(max)), 'NA'), 
db_name(req.database_id) [DBName], 
req.logical_reads,
[dec].client_net_address,
req.granted_query_memory * 1.0 /128 [memoryMB],
SUM(ddtsu.user_objects_alloc_page_count + ddtsu.user_objects_dealloc_page_count + ddtsu.internal_objects_alloc_page_count + ddtsu.internal_objects_dealloc_page_count) * 1.0 /128 
/*from sys.dm_db_task_space_usage tsu where tsu.exec_context_id = ddtsu.exec_context_id and tsu.session_id = req.session_id and req.request_id = tsu.request_id and req.database_id = tsu.database_id*/
 [TempDBMB],
req.statement_start_offset,
req.statement_end_offset,
@@SERVERNAME [ServerName] 
from sys.dm_exec_requests req
outer apply sys.dm_exec_sql_text (req.sql_handle) dest
outer apply sys.dm_exec_query_plan(req.plan_handle) deqp
inner join sys.dm_exec_connections [dec]
	on dec.connection_id = req.connection_id
inner join sys.dm_db_task_space_usage ddtsu
	on ddtsu.session_id = req.session_id
	and ddtsu.request_id = req.request_id	
where req.status in ('suspended', 'runnable', 'running')
and dest.[text] not like '%usp_getwaitstats%'
and dest.[text] not like '%usp_GetRequests%'
group by req.session_id, 
req.request_id,
req.command, 
req.start_time, 
req.status,
req.sql_handle, 
req.plan_handle, 
dest.objectid,
req.wait_time, 
req.wait_type, 
req.wait_resource, 
req.last_wait_type,
req.cpu_time, 
req.total_elapsed_time, 
req.reads, 
req.writes,
dest.text, 
isnull(cast(deqp.query_plan as varchar(max)), 'NA'), 
db_name(req.database_id) , 
req.logical_reads,
[dec].client_net_address,
req.granted_query_memory * 1.0 /128,
req.statement_start_offset,
req.statement_end_offset/*,
@@SERVERNAME */




declare @sessionid smallint, @request_id int, @starttime datetime, @collectiontime datetime = getdate()
declare @sqlhandle varbinary(64), @startoffset int, @endoffset int



declare request_cur cursor fast_forward for
select session_id, request_id, start_time, [sql_handle], startoffset, endoffset from @requests
open request_cur
fetch next from request_cur 
into @sessionid, @request_id, @starttime, @sqlhandle, @startoffset, @endoffset
while (@@FETCH_STATUS = 0)
begin


	--select * from @requests
	if exists(
	select 1 from [dblog].[requests] where session_id = @sessionid and start_time = @starttime and request_id = @request_id and [sql_handle] = @sqlhandle and Statement_StartOffSet = @startoffset and Statement_EndOffSet = @endoffset
	)
	begin
		delete from [dblog].[requests] where session_id = @sessionid and start_time = @starttime and request_id = @request_id and [sql_handle] = @sqlhandle and Statement_StartOffSet = @startoffset and Statement_EndOffSet = @endoffset
		insert into [dblog].[requests]
		select *, @collectiontime,0 from @requests where session_id = @sessionid and start_time = @starttime and request_id = @request_id and [sql_handle] = @sqlhandle and startoffset = @startoffset and endoffset = @endoffset


		--select 'Existing'
		--select *, @collectiontime,0 from @requests where session_id = @sessionid and start_time = @starttime and request_id = @request_id and [sql_handle] = @sqlhandle
	end

	if not exists(select 1 from [dblog].[requests] where session_id = @sessionid and start_time = @starttime and request_id = @request_id and [sql_handle] = @sqlhandle and Statement_StartOffSet = @startoffset and Statement_EndOffSet = @endoffset)
	begin		
		insert into [dblog].[requests]
		select *, @collectiontime,0 from @requests where session_id = @sessionid and start_time = @starttime and request_id = @request_id and [sql_handle] = @sqlhandle and startoffset = @startoffset and endoffset = @endoffset

		--select 'New'
		--select *, @collectiontime,0 from @requests where session_id = @sessionid and start_time = @starttime and request_id = @request_id and [sql_handle] = @sqlhandle
	end

fetch next from request_cur 
into @sessionid, @request_id, @starttime, @sqlhandle, @startoffset, @endoffset
end
close request_cur
deallocate request_cur

Go








use DBLOG
GO


create procedure dblog.sp_exportRequestsAndUpdate
as
declare @exportto datetime
select @exportto =  dateadd(MINUTE, -7, getdate())

SELECT 
	[session_id]
      ,[request_id]
      ,[command]
      ,[start_time]
      ,[status]
      ,[sql_handle]
      ,[plan_handle]
      ,[object_id]
      ,[wait_time]
      ,[wait_type]
      ,[wait_resource]
      ,[last_wait_type]
      ,[cpu_time]
      ,[total_elapsed_time]
      ,[reads]
      ,[writes]
      ,[text]
      ,[query_plan]
      ,[databasename]
      ,[logical_reads]
      ,[ClientIP]
      ,[MemoryMB]
      ,[TempDBMB]
      ,[Statement_StartOffSet]
      ,[Statement_EndOffSet]
      ,[ServerName]
      ,[collectiondate]
  FROM [DBLOG].[DBLog].[Requests]
  where exportstatus = 0
  and collectiondate <= @exportto


  -- mark for cleanup
  update [DBLOG].[DBLog].[Requests]
  set exportstatus = 1
  where exportstatus = 0 and collectiondate <= @exportto

  GO



  use DBLOG
GO
use DBLOG
GO

create procedure dblog.sp_ClearRequests
as

Delete from DBLOG.requests
where ExportStatus = 1
GO



/* Add the property for delay */

USE DBLOG
GO

  if not exists (select 1 from [DBLog].[MiscProperties] where propertyname = 'usp_GetRequestDelaySeconds')
  begin
	insert into [DBLog].[MiscProperties] 
	select 'usp_GetRequestDelaySeconds', '00:00:05'
  end

USE [msdb]
GO

/****** Object:  Job [dblog.getRequestsJob]    Script Date: 3/30/2017 2:03:29 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/30/2017 2:03:30 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'dblog.getRequestsJob', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [exec dblog.usp_GetRequests]    Script Date: 3/30/2017 2:03:32 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'exec dblog.usp_GetRequests', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=1000, 
		@retry_interval=1, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @delay varchar(50)
SELECT @delay = propertyvalue  from  [DBLOG].[DBLog].[MiscProperties] where propertyname = ''usp_GetRequestDelaySeconds''

while (1=1)
begin
	
	exec dblog.usp_GetRequests
	waitfor delay @delay
	
end', 
		@database_name=N'DBLOG', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'getRequests_whenagentstarts', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170330, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = @@servername
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


USE DBLOG
GO





USE [msdb]
GO

/****** Object:  Job [DBLOG.ClearRequestsJob]    Script Date: 3/30/2017 2:18:30 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/30/2017 2:18:30 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBLOG.ClearRequestsJob', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [dblog.sp_ClearRequests]    Script Date: 3/30/2017 2:18:30 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'dblog.sp_ClearRequests', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dblog.sp_ClearRequests', 
		@database_name=N'DBLOG', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'onehour_dblog.sp_ClearRequests', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170330, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = @@servername
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


use DBLOG
GO