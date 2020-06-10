create proc [DBLog].[usp_BackupTransfer_Obsolete] @transferID int
as
-- THIS SP WILL RESET THE BACKUP TRANSFER JOB
-- SO THAT BACKUP TRANSFER COULD BE RESTARTED
update dblog.Backup_transfer_Job
set Status ='Obsolete'
where Transfer_ID = @transferID