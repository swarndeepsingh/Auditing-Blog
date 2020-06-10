USE [msdb]
GO

DECLARE @ReturnCode INT
DECLARE @jobId binary(16) 
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC  msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'

END
/*
set @jobId = NULL
/*
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBLog_Backup_Configuration_Reset')
BEGIN*/
	SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'DBLog_Backup_Configuration_Reset') 
	IF (@jobId IS NOT NULL) 
	BEGIN 
		EXEC msdb.dbo.sp_delete_job @jobId 
	END
/*END*/*/


IF NOT EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBLog_Backup_Configuration_Reset')
BEGIN
				EXEC  msdb.dbo.sp_add_job @job_name=N'DBLog_Backup_Configuration_Reset', 
				@enabled=1, 
				@notify_level_eventlog=0, 
				@notify_level_email=2, 
				@notify_level_netsend=2, 
				@notify_level_page=2, 
				@delete_level=0, 
				@category_name=N'[Uncategorized (Local)]', 
				@owner_login_name=N'sa', @job_id = @jobId OUTPUT
		
		
		EXEC msdb.dbo.sp_add_jobserver @job_name=N'DBLog_Backup_Configuration_Reset', @server_name = @@SERVERNAME
		
		
		
		EXEC msdb.dbo.sp_add_jobstep @job_name=N'DBLog_Backup_Configuration_Reset', @step_name=N'Backup Auto Configure', 
				@step_id=1, 
				@cmdexec_success_code=0, 
				@on_success_action=1, 
				@on_fail_action=2, 
				@retry_attempts=0, 
				@retry_interval=0, 
				@os_run_priority=0, @subsystem=N'TSQL', 
				@command=N'EXEC dblog.usp_Backup_Auto_Configure', 
				@database_name=N'DBLog', 
				@flags=0
		
		
		
		EXEC msdb.dbo.sp_update_job @job_name=N'DBLog_Backup_Configuration_Reset', 
				@enabled=1, 
				@start_step_id=1, 
				@notify_level_eventlog=0, 
				@notify_level_email=2, 
				@notify_level_netsend=2, 
				@notify_level_page=2, 
				@delete_level=0, 
				@description=N'', 
				@category_name=N'[Uncategorized (Local)]', 
				@owner_login_name=N'sa', 
				@notify_email_operator_name=N'', 
				@notify_netsend_operator_name=N'', 
				@notify_page_operator_name=N''
		
		
		
		DECLARE @schedule_id int
		EXEC msdb.dbo.sp_add_jobschedule @job_name=N'DBLog_Backup_Configuration_Reset', @name=N'Every 6 hours Backup ReConfigure', 
				@enabled=1, 
				@freq_type=4, 
				@freq_interval=1, 
				@freq_subday_type=8, 
				@freq_subday_interval=5, 
				@freq_relative_interval=0, 
				@freq_recurrence_factor=1, 
				@active_start_date=20120620, 
				@active_end_date=99991231, 
				@active_start_time=0, 
				@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
		select @schedule_id
END
GO