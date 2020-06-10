USE [msdb]
GO


DECLARE @jobId binary(16) 
set @jobId = NULL

SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'Audit_Trace') 
IF (@jobId IS NOT NULL) 
BEGIN 
    EXEC msdb.dbo.sp_delete_job @jobId 
END


set @jobId = NULL

SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'Audit Trace') 
IF (@jobId IS NOT NULL) 
BEGIN 
    EXEC msdb.dbo.sp_delete_job @jobId 
END


set @jobId = NULL

SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'DBLog Audit Trace') 
IF (@jobId IS NOT NULL) 
BEGIN 
    EXEC msdb.dbo.sp_delete_job @jobId 
END


set @jobId = NULL

SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'DBLog_Audit_Trace') 
IF (@jobId IS NOT NULL) 
BEGIN 
    EXEC msdb.dbo.sp_delete_job @jobId 
END



/****** Object:  Job [Audit_Trace]    Script Date: 12/20/2011 14:29:32 ******/

DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBA_Traces]]    Script Date: 12/20/2011 14:29:32 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBA_Traces' AND category_class=1)
BEGIN
EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBA_Traces'


END

IF NOT EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'Audit_Trace')
BEGIN

	EXEC msdb.dbo.sp_add_job @job_name=N'Audit_Trace', 
			@enabled=1, 
			@notify_level_eventlog=0, 
			@notify_level_email=0, 
			@notify_level_netsend=0, 
			@notify_level_page=0, 
			@delete_level=0, 
			@description=N'This job runs the user defined traces for audit system.', 
			@category_name=N'DBA_Traces', 
			@owner_login_name=N'sa', @job_id = @jobId OUTPUT



EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = @@servername





EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Enable Advanced Options', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'sp_configure ''show advanced options'',1
reconfigure with override
GO', 
		@database_name=N'DBLog', 
		@flags=0




EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Refresh Login List', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'[DBLOG].sp_GetAuditableLogins', 
		@database_name=N'DBLog', 
		@flags=0




EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Initiate', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'[DBLog].sp_ValidateJobRun', 
		@database_name=N'DBLog', 
		@flags=0




EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Import_Traces', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'[DBLog].usp_Import_Trace', 
		@database_name=N'DBLog', 
		@flags=0




EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete Old Traces', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [DBLog].usp_Cleanup_Traces ''''', 
		@database_name=N'DBLog', 
		@flags=0





EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Fix Orphaned Traces', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec DBLog.usp_Trace_FixOrphanedTrace', 
		@database_name=N'DBLog', 
		@flags=0


/*
EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Disable Advanced Options', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'sp_configure ''show advanced options'',0
reconfigure with override
GO', 
		@database_name=N'DBLog', 
		@flags=0
*/



EXEC msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1


declare @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'2 Hours', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=2, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20101029, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959,
		@schedule_id = @schedule_id OUTPUT
END
GO


-- Reset the Audit to run once in 24 hours


update dblog.DBLog.Trace_Properties
set PropertyValue = '1440'
where PropertyName = 'Interval'

GO