USE [msdb]
GO
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
	EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
END

IF NOT EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBLog Full Backup')
BEGIN

		DECLARE @jobId BINARY(16)
		EXEC msdb.dbo.sp_add_job @job_name=N'DBLog Full Backup', 
				@enabled=0, 
				@notify_level_eventlog=0, 
				@notify_level_email=0, 
				@notify_level_netsend=0, 
				@notify_level_page=0, 
				@delete_level=0, 
				@description=N'No description available.', 
				@category_name=N'[Uncategorized (Local)]', 
				@owner_login_name=N'sa', @job_id = @jobId OUTPUT

		EXEC  msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = @@SERVERNAME

		EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Full Backup', 
				@step_id=1, 
				@cmdexec_success_code=0, 
				@on_success_action=1, 
				@on_success_step_id=0, 
				@on_fail_action=2, 
				@on_fail_step_id=0, 
				@retry_attempts=0, 
				@retry_interval=0, 
				@os_run_priority=0, @subsystem=N'TSQL', 
				@command=N'
				dblog.usp_Backup_Auto_Configure

				declare @backupid int, @i int
		declare backup_cursor Cursor for
		select backup_id from [DBLog].[DBLog].[Backup_info] where Enabled = 1 and backuptype = ''D''
		open backup_cursor
		fetch next from backup_cursor into @backupid
		while @@fetch_status = 0
		BEGIN
			EXEC DBLog.backup_dr_transfer @backupid, @i
			fetch next from backup_cursor into @backupid
		END
		Close backup_cursor
		deallocate backup_cursor
		', 
				@database_name=N'DBLog', 
				@flags=0


		EXEC  msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1


		EXEC msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Saturday_2_am_full_backup', 
				@enabled=1, 
				@freq_type=8, 
				@freq_interval=64, 
				@freq_subday_type=1, 
				@freq_subday_interval=0, 
				@freq_relative_interval=0, 
				@freq_recurrence_factor=1, 
				@active_start_date=20120620, 
				@active_end_date=99991231, 
				@active_start_time=20000, 
				@active_end_time=235959

END

