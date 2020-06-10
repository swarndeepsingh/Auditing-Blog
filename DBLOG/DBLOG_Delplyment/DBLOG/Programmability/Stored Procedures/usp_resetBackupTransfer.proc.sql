CREATE proc [DBLog].[usp_resetBackupTransfer] @transferID int
as
-- THIS SP WILL RESET THE BACKUP TRANSFER JOB
-- SO THAT BACKUP TRANSFER COULD BE RESTARTED
update dblog.Backup_transfer_Job
set Status ='Pending', startdate = NULL, enddate = NULL, [Message] = NULL
where Transfer_ID = @transferID