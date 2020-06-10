CREATE proc [DBLog].[usp_FileCleanup_Prepare]
as
-- This SP will get list of files which needs to be deleted or due to be deleted
-- at the time when this SP runs.
-- For remote files

INSERT INTO DBLog.Backup_Delete_Files
           ([Backup_ID]
           ,[Backup_Job_ID]
           ,[File_Location]
           ,[Location_Type]
           ,[Status]
           ,[locationID])
select a.backup_id, a.backup_job_id,  a.FileName_Mirror, 'Remote'
, 'Pending', b.MirrorLocationID from DBLog.Backup_Jobs a with (NOLOCK)
join dblog.Backup_info b with (NOLOCK)
	on a.Backup_ID = b.Backup_ID
where a.filename_mirror <> 'No Remote backup' and a.status = 'Completed'
and a.retainUntil_remote < = getdate() -8
and a.Backup_Job_ID not in (select Backup_Job_ID from DBLog.Backup_Delete_Files where Location_Type = 'Remote')

-- local files
INSERT INTO DBLog.Backup_Delete_Files
           ([Backup_ID]
           ,[Backup_Job_ID]
           ,[File_Location]
           ,[Location_Type]
           ,[Status]
           ,[LocationID])
select a.backup_id, a.backup_job_id,  a.FileName, 'Local'
, 'Pending', b.BackupLocationID from DBLog.Backup_Jobs a with (NOLOCK)
join dblog.Backup_info b with (NOLOCK)
	on a.Backup_ID = b.Backup_ID
where  a.status = 'Completed'
and a.retainUntil_local < = getdate() -8
and a.Backup_Job_ID not in (select Backup_Job_ID from DBLog.Backup_Delete_Files where Location_Type = 'Local')