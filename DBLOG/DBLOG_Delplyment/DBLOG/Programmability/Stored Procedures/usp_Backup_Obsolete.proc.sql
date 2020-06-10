Create proc [DBLog].[usp_Backup_Obsolete] @backup_job_id int
as
update DBLog.Backup_Jobs 
set Status = 'Cancelled'
where Backup_Job_ID=@backup_job_id