
/*USE [msdb]
GO

DECLARE @jobId binary(16) 
set @jobId = NULL

IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBLOG.Alert_Blocking')
BEGIN
	SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'DBLOG.Alert_Blocking') 
	IF (@jobId IS NOT NULL) 
	BEGIN 
		EXEC msdb.dbo.sp_delete_job @jobId 
	END
END

set @jobId = NULL

DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 02/06/2013 14:21:03 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
END


IF  NOT EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBLOG.Alert_Blocking')
BEGIN
	EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBLOG.Alert_Blocking', 
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

	/****** Object:  Step [Exec Stored Procedure]    Script Date: 02/06/2013 14:21:03 ******/
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Execute SP to find out blockings', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @emailprofile varchar(50), @recipients varchar(2000)
select top 1 @emailprofile = [Profile], @recipients = [recipients] from DBLog.DBLog.EmailProfiles
exec [DBLog].[usp_Alert_Blocking_OpenTransaction] @emailprofile,  @recipients', 
		@database_name=N'DBLog', 
		@flags=0
	

	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	
	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every9minutes', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=9, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20140423, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959

END
*/