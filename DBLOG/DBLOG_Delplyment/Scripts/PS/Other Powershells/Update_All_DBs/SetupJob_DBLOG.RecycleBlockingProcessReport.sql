USE [msdb]
GO


declare @version int
declare @productversion varchar(20)
select @productversion = cast(serverproperty('productversion') as varchar(20))


select @version= substring(@productversion,0,charindex('.',@productversion,0))

-- SQL Server is > 2005
if (@version > 9)
begin

if not exists(select name from dbo.sysjobs where name = 'DBLOG.RecycleBlockingProcessReport')
begin

	/****** Object:  Job [DBLOG.RecycleBlockingProcessReport]    Script Date: 11/11/2017 7:26:56 AM ******/
	BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0
	/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/11/2017 7:26:56 AM ******/
	IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
	BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	END

	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBLOG.RecycleBlockingProcessReport', 
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
	/****** Object:  Step [usp_BlockProcess_WorkFlow]    Script Date: 11/11/2017 7:26:57 AM ******/
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'usp_BlockProcess_WorkFlow', 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_success_step_id=0, 
			@on_fail_action=2, 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'TSQL', 
			@command=N'[DBLog].[usp_BlockProcess_WorkFlow] 1', 
			@database_name=N'DBLOG', 
			@flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'EveryOneHour_blockingProcessing', 
			@enabled=1, 
			@freq_type=4, 
			@freq_interval=1, 
			@freq_subday_type=8, 
			@freq_subday_interval=1, 
			@freq_relative_interval=0, 
			@freq_recurrence_factor=0, 
			@active_start_date=20171111, 
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
END
ELSE if  exists(select name from dbo.sysjobs where name = 'DBLOG.RecycleBlockingProcessReport')
print 'Job already exists, quitting'

END
GO
USE DBLOG
GO
