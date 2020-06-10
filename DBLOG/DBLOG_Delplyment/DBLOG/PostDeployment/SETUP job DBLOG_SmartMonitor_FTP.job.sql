USE [msdb]
GO

DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 03/06/2012 19:47:28 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
END

IF NOT EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBLOG_SmartMonitor_FTP')
BEGIN
	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBLOG_SmartMonitor_FTP', 
			@enabled=1, 
			@notify_level_eventlog=0, 
			@notify_level_email=0, 
			@notify_level_netsend=0, 
			@notify_level_page=0, 
			@delete_level=0, 
			@description=N'No description available.', 
			@category_name=N'[Uncategorized (Local)]', 
			@owner_login_name=N'sa', @job_id = @jobId OUTPUT
			
	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = @@SERVERNAME
	/****** Object:  Step [FTP_To_SM]    Script Date: 03/06/2012 19:47:28 ******/
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'FTP_To_SM', 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_success_step_id=0, 
			@on_fail_action=2, 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'TSQL', 
			@command=N'exec dblog.usp_ftp_PutFile', 
			@database_name=N'DBLog', 
			@flags=0
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'FTP_SM_6AM', 
			@enabled=1, 
			@freq_type=4, 
			@freq_interval=1, 
			@freq_subday_type=1, 
			@freq_subday_interval=0, 
			@freq_relative_interval=0, 
			@freq_recurrence_factor=0, 
			@active_start_date=20120306, 
			@active_end_date=99991231, 
			@active_start_time=60000, 
			@active_end_time=235959



END


