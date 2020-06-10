
create proc [DBLog].[usp_BackupList] @status varchar(20)
as
if @status = 'failed'
begin
	select a.Backup_Job_ID
	, a.Backup_ID
	, b.BackupName
	, b.CompressBackup
	, b.DR_Transfer
	, b.FrequencyName
	, a.[FileName] as 'OnSite_Path'
	, a.FileName_Mirror as 'OffSite_Path'
	, a.[status]
	, a.Backup_Start_Time
	, a.Backup_End_Time
	, a.retainUntil_local as 'OnSite_Purge_Date'
	, a.retainUntil_remote as 'OffSite_Purge_Date'
	, cast(isnull(a.BackupSizeKB,0)/1024/1024 as money) as 'Backup_Size_MB'
	 from dblog.backup_jobs a with (NOLOCK)
	 join dblog.Backup_info b with (NOLOCK)
		on a.Backup_ID = b.Backup_ID
	where a.status not in ('Completed','Started','Obsolete','Cancelled')
	order by Backup_Job_ID desc
end
else if @status = 'All'
begin
	select a.Backup_Job_ID
	, a.Backup_ID
	, b.BackupName
	, b.CompressBackup
	, b.DR_Transfer
	, b.FrequencyName
	, a.[FileName] as 'OnSite_Path'
	, a.FileName_Mirror as 'OffSite_Path'
	, a.[status]
	, a.Backup_Start_Time
	, a.Backup_End_Time
	, a.retainUntil_local as 'OnSite_Purge_Date'
	, a.retainUntil_remote as 'OffSite_Purge_Date'
	, cast(isnull(a.BackupSizeKB,0)/1024/1024 as money) as 'Backup_Size_MB'
	 from dblog.backup_jobs a with (NOLOCK)
	 join dblog.Backup_info b with (NOLOCK)
		on a.Backup_ID = b.Backup_ID
	order by Backup_Job_ID desc
end
else 
begin
	select top 500 a.Backup_Job_ID
	, a.Backup_ID
	, b.BackupName
	, b.CompressBackup
	, b.DR_Transfer
	, b.FrequencyName
	, a.[FileName] as 'OnSite_Path'
	, a.FileName_Mirror as 'OffSite_Path'
	, a.[status]
	, a.Backup_Start_Time
	, a.Backup_End_Time
	, a.retainUntil_local as 'OnSite_Purge_Date'
	, a.retainUntil_remote as 'OffSite_Purge_Date'
	, cast(isnull(a.BackupSizeKB,0)/1024/1024 as money) as 'Backup_Size_MB'
	 from dblog.backup_jobs a with (NOLOCK)
	 join dblog.Backup_info b with (NOLOCK)
		on a.Backup_ID = b.Backup_ID
	where a.status = @status
	order by Backup_Job_ID desc
end