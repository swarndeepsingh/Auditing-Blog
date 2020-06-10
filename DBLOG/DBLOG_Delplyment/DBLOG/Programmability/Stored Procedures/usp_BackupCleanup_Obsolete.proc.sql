create proc [DBLog].[usp_BackupCleanup_Obsolete] @delete_id int
as
update DBLog.Backup_Delete_Files 
set Status = 'Obsolete'
where delete_id=@delete_id