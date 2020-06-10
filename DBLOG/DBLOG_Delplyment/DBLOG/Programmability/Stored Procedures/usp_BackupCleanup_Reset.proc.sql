create proc [DBLog].[usp_BackupCleanup_Reset] @delete_id int
as
update DBLog.Backup_Delete_Files 
set Status = 'Pending', date_scheduled = GETDATE(), Start_Time = NULL, end_time = NULL
where delete_id=@delete_id