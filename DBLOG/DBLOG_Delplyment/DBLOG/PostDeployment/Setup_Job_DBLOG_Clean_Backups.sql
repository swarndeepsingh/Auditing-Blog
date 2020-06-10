USE [msdb]
GO

DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 01/10/2012 13:37:37 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
END

IF NOT EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBLOG_Backup_Cleanup')
BEGIN

	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBLOG_Backup_Cleanup', 
			@enabled=1, 
			@notify_level_eventlog=0, 
			@notify_level_email=0, 
			@notify_level_netsend=0, 
			@notify_level_page=0, 
			@delete_level=0, 
			@description=N'No description available.', 
			@category_name=N'[Uncategorized (Local)]', 
			@owner_login_name=N'sa', @job_id = @jobId OUTPUT


	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name =@@servername
	
	
	/****** Object:  Step [Cleanup]    Script Date: 01/10/2012 13:37:37 ******/
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Cleanup', 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_success_step_id=0, 
			@on_fail_action=2, 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'TSQL', 
			@command=N'exec DBLOG.usp_FileCleanup_Prepare
	GO

	exec [DBLog].[usp_Delete_Files]
	GO', 
			@database_name=N'DBLOG', 
			@flags=0
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'10 Minutes', 
			@enabled=1, 
			@freq_type=4, 
			@freq_interval=1, 
			@freq_subday_type=4, 
			@freq_subday_interval=10, 
			@freq_relative_interval=0, 
			@freq_recurrence_factor=0, 
			@active_start_date=20120106, 
			@active_end_date=99991231, 
			@active_start_time=0, 
			@active_end_time=235959

END



