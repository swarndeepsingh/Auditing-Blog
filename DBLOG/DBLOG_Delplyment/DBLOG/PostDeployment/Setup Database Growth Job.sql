USE [msdb]

DECLARE @jobId binary(16) 
set @jobId = NULL
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'Collect DB Usage DBLog')
BEGIN
SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'Collect DB Usage DBLog') 
IF (@jobId IS NOT NULL) 
BEGIN 
    EXEC msdb.dbo.sp_delete_job @jobId 
END
END

set @jobId = NULL
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'Collect DB Usage Logging')
BEGIN
SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'Collect DB Usage Logging') 
IF (@jobId IS NOT NULL) 
BEGIN 
    EXEC msdb.dbo.sp_delete_job @jobId 
END
END

set @jobId = NULL
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'Collect DB Usage MainStream')
BEGIN
SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'Collect DB Usage MainStream') 
IF (@jobId IS NOT NULL) 
BEGIN 
    EXEC msdb.dbo.sp_delete_job @jobId 
END
END

set @jobId = NULL
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBLog Collect DB Usage')
BEGIN
SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'DBLog Collect DB Usage') 
IF (@jobId IS NOT NULL) 
BEGIN 
    EXEC msdb.dbo.sp_delete_job @jobId 
END
END

set @jobId = NULL

IF NOT EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBLog Collect DB Usage')
BEGIN

EXEC  msdb.dbo.sp_add_job @job_name=N'DBLog Collect DB Usage', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
select @jobId

EXEC msdb.dbo.sp_add_jobserver @job_name=N'DBLog Collect DB Usage', @server_name =@@servername

USE [msdb]

EXEC msdb.dbo.sp_add_jobstep @job_name=N'DBLog Collect DB Usage', @step_name=N'DBLog', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Exec [DBLog].[sp_Collect_DBUsage_Info]', 
		@database_name=N'DBLog', 
		@flags=0



USE [msdb]

EXEC msdb.dbo.sp_update_job @job_name=N'DBLog Collect DB Usage', 
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

USE [msdb]

DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'DBLog Collect DB Usage', @name=N'3AM Collect DB Usage DBLog', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20111024, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id

END


GO