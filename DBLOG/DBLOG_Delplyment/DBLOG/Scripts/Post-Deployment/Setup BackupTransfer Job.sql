USE [msdb]
GO 
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBA_Backup' AND category_class=1)
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBA_Backup'


IF NOT EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'Backup_Transfer')
BEGIN
DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backup_Transfer', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job will transfer the backups to DR.', 
		@category_name=N'DBA_Backup', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT


EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = @@servername


EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Transfer', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dblog.usp_Backup_Transfer_Files', 
		@database_name=N'DBLog', 
		@flags=0

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1

EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'10-5AM', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20111229, 
		@active_end_date=99991231, 
		@active_start_time=220000, 
		@active_end_time=50000, 
		@schedule_uid=N'775ebdee-ff80-4783-ab38-1c3f66fa4d45'




END