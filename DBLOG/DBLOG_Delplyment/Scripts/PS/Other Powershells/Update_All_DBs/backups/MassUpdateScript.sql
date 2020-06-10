use DBLOG

CREATE TABLE DBLOG.WaitStats 
(
CaptureDataID bigint, 
WaitType varchar(200), 
wait_S decimal(20,5), 
Resource_S decimal (20,5), 
Signal_S decimal (20,5), 
WaitCount bigint, 
Avg_Wait_S numeric(10, 6), 
Avg_Resource_S numeric(10, 6),
Avg_Signal_S numeric(10, 6), 
CaptureDate datetime,
[ExportStatus] [bit] NOT NULL CONSTRAINT [DF_WaitStats_ExportStatus]  DEFAULT ((0))
)


CREATE TABLE DBLOG.BenignWaits (
WaitType varchar(200)
)
GO

CREATE TABLE DBLOG.CaptureData (
ID bigint identity PRIMARY KEY,
StartTime datetime,
EndTime datetime,
ServerName varchar(500),
PullPeriod int
)
GO


CREATE PROCEDURE dblog.usp_GetWaitStats 
    @WaitTimeSec INT = 60,
    @StopTime DATETIME = NULL
AS
BEGIN
    DECLARE @CaptureDataID int
    /* Create temp tables to capture wait stats to compare */
    IF OBJECT_ID('tempdb..#WaitStatsBench') IS NOT NULL
        DROP TABLE #WaitStatsBench
    IF OBJECT_ID('tempdb..#WaitStatsFinal') IS NOT NULL
        DROP TABLE #WaitStatsFinal
 
    CREATE TABLE #WaitStatsBench (WaitType varchar(200), wait_S decimal(20,5), Resource_S decimal (20,5), Signal_S decimal (20,5), WaitCount bigint)
    CREATE TABLE #WaitStatsFinal (WaitType varchar(200), wait_S decimal(20,5), Resource_S decimal (20,5), Signal_S decimal (20,5), WaitCount bigint)
 
    DECLARE @ServerName varchar(300)
    SELECT @ServerName = convert(nvarchar(128), serverproperty('servername'))
     
    /* Insert master record for capture data */
    INSERT INTO DBLOG.CaptureData (StartTime, EndTime, ServerName,PullPeriod)
    VALUES (GETDATE(), NULL, @ServerName, @WaitTimeSec)
     
    SELECT @CaptureDataID = SCOPE_IDENTITY()
      
/* Loop through until time expires  */
    IF @StopTime IS NULL
        SET @StopTime = DATEADD(hh, 1, getdate())
    WHILE GETDATE() < @StopTime
    BEGIN
 
        /* Get baseline */
         
        INSERT INTO #WaitStatsBench (WaitType, wait_S, Resource_S, Signal_S, WaitCount)
        SELECT
                wait_type,
                wait_time_ms / 1000.0 AS WaitS,
                (wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceS,
                signal_wait_time_ms / 1000.0 AS SignalS,
                waiting_tasks_count AS WaitCount
            FROM sys.dm_os_wait_stats
            WHERE wait_time_ms > 0.01 
            AND wait_type NOT IN ( SELECT WaitType FROM DBLOG.BenignWaits)
         
 
        /* Wait a few minutes and get final snapshot */
        WAITFOR DELAY @WaitTimeSec;
 
        INSERT INTO #WaitStatsFinal (WaitType, wait_S, Resource_S, Signal_S, WaitCount)
        SELECT
                wait_type,
                wait_time_ms / 1000.0 AS WaitS,
                (wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceS,
                signal_wait_time_ms / 1000.0 AS SignalS,
                waiting_tasks_count AS WaitCount
            FROM sys.dm_os_wait_stats
            WHERE wait_time_ms > 0.01
            AND wait_type NOT IN ( SELECT WaitType FROM DBLOG.BenignWaits)
         
        DECLARE @CaptureTime datetime 
        SET @CaptureTime = getdate()
 
        INSERT INTO DBLOG.WaitStats (CaptureDataID, WaitType, Wait_S, Resource_S, Signal_S, WaitCount, Avg_Wait_S, Avg_Resource_S,Avg_Signal_S, CaptureDate)
        SELECT  @CaptureDataID,
            f.WaitType,
            f.wait_S - b.wait_S as Wait_S,
            f.Resource_S - b.Resource_S as Resource_S,
            f.Signal_S - b.Signal_S as Signal_S,
            f.WaitCount - b.WaitCount as WaitCounts,
            CAST(CASE WHEN f.WaitCount - b.WaitCount = 0 THEN 0 ELSE (f.wait_S - b.wait_S) / (f.WaitCount - b.WaitCount) END AS numeric(10, 6))AS Avg_Wait_S,
            CAST(CASE WHEN f.WaitCount - b.WaitCount = 0 THEN 0 ELSE (f.Resource_S - b.Resource_S) / (f.WaitCount - b.WaitCount) END AS numeric(10, 6))AS Avg_Resource_S,
            CAST(CASE WHEN f.WaitCount - b.WaitCount = 0 THEN 0 ELSE (f.Signal_S - b.Signal_S) / (f.WaitCount - b.WaitCount) END AS numeric(10, 6))AS Avg_Signal_S,
            @CaptureTime
        FROM #WaitStatsFinal f
        LEFT JOIN #WaitStatsBench b ON (f.WaitType = b.WaitType)
        WHERE (f.wait_S - b.wait_S) > 0.0 -- Added to not record zero waits in a time interval.
         
        TRUNCATE TABLE #WaitStatsBench
        TRUNCATE TABLE #WaitStatsFinal
 END -- END of WHILE
  
 /* Update Capture Data meta-data to include end time */
 UPDATE DBLOG.CaptureData
 SET EndTime = GETDATE()
 WHERE ID = @CaptureDataID
END

GO




use DBLOG
GO

create procedure dblog.sp_clearWaitStats
as

Delete from DBLOG.WaitStats
where ExportStatus = 1
GO



USE [msdb]
GO

/****** Object:  Job [dblog.clearWaitStatus]    Script Date: 3/17/2017 2:01:25 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/17/2017 2:01:25 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'dblog.clearWaitStatus', 
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
/****** Object:  Step [deletewaitstatus]    Script Date: 3/17/2017 2:01:25 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'deletewaitstatus', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dblog.sp_clearWaitStats', 
		@database_name=N'DBLOG', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'onehour', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170317, 
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





USE [msdb]
GO

/****** Object:  Job [dblog.GetWaitStatsJob]    Script Date: 3/17/2017 1:00:32 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/17/2017 1:00:32 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'dblog.GetWaitStatsJob', 
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
/****** Object:  Step [GetWaitStats]    Script Date: 3/17/2017 1:00:32 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'GetWaitStats', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'set nocount on
while (1=1)
begin
	DECLARE @EndTime datetime, @WaitSeconds int
	SELECT @EndTime = DATEADD(SECOND, 300, getdate()),
	@WaitSeconds = 300
 
	EXEC dblog.usp_GetWaitStats
	@WaitTimeSec = @WaitSeconds,
	@StopTime = @EndTime
end', 
		@database_name=N'DBLOG', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'StartWhenSQLAgentStarts', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170317, 
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

USE DBLOG
GO
delete from  DBLOG.BenignWaits
GO


INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('CLR_SEMAPHORE')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('LAZYWRITER_SLEEP')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES  ('RESOURCE_QUEUE')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('SLEEP_TASK')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('SLEEP_SYSTEMTASK')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('SQLTRACE_BUFFER_FLUSH')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES  ('WAITFOR')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('LOGMGR_QUEUE')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('CHECKPOINT_QUEUE')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('REQUEST_FOR_DEADLOCK_SEARCH')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('XE_TIMER_EVENT')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES  ('BROKER_TO_FLUSH')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('BROKER_TASK_STOP')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('CLR_MANUAL_EVENT')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('CLR_AUTO_EVENT')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('DISPATCHER_QUEUE_SEMAPHORE')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('FT_IFTS_SCHEDULER_IDLE_WAIT')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('XE_DISPATCHER_WAIT')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('XE_DISPATCHER_JOIN')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('BROKER_EVENTHANDLER')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('TRACEWRITE')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('FT_IFTSHC_MUTEX')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('SQLTRACE_INCREMENTAL_FLUSH_SLEEP')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('BROKER_RECEIVE_WAITFOR')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('ONDEMAND_TASK_QUEUE')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('DBMIRROR_EVENTS_QUEUE')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('DBMIRRORING_CMD')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('BROKER_TRANSMITTER')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('SQLTRACE_WAIT_ENTRIES')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('SLEEP_BPOOL_FLUSH')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('SQLTRACE_LOCK')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('DIRTY_PAGE_POLL')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('SP_SERVER_DIAGNOSTICS_SLEEP')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('HADR_FILESTREAM_IOMGR_IOCOMPLETION')
INSERT INTO DBLOG.BenignWaits (WaitType)
VALUES ('HADR_WORK_QUEUE') 
insert DBLOG.BenignWaits (WaitType) 
VALUES ('QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP');
insert DBLOG.BenignWaits (WaitType) 
VALUES ('QDS_PERSIST_TASK_MAIN_LOOP_SLEEP');
GO
