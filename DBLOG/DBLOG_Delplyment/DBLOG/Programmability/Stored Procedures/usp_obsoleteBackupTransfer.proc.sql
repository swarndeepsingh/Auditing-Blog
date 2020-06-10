create proc [DBLog].[usp_obsoleteBackupTransfer] @transferID int
as
-- THIS SP WILL RESET THE BACKUP TRANSFER JOB
-- SO THAT BACKUP TRANSFER COULD BE RESTARTED
update dblog.Backup_transfer_Job
set Status ='Obsoleted'
where Transfer_ID = @transferID