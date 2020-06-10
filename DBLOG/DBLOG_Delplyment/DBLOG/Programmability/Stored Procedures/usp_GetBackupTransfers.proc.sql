
CREATE proc [DBLog].[usp_GetBackupTransfers] @status varchar(20) 
as
if @status not in ('Error','All')
begin
Select
a.Transfer_ID, b.status as 'Backup_Status', c.BackupName, a.[status] as 'Transfer_Status'
, a.[Source],a.[Destination],a.startdate
, a.enddate, a.Message
from dblog.Backup_transfer_Job a with (NOLOCK)
join dblog.Backup_Jobs b with (NOLOCK)
	on a.Backup_Job_ID = b.Backup_Job_ID
join dblog.Backup_info c with (NOLOCK)
	on b.Backup_ID = c.Backup_ID
where a.Status = @status
order by Transfer_ID desc


end

 if @status ='All'
begin
Select top 500
a.Transfer_ID, b.status as 'Backup_Status', c.BackupName, a.[status] as 'Transfer_Status'
, a.[Source],a.[Destination],a.startdate
, a.enddate, a.Message
from dblog.Backup_transfer_Job a with (NOLOCK)
join dblog.Backup_Jobs b with (NOLOCK)
	on a.Backup_Job_ID = b.Backup_Job_ID
join dblog.Backup_info c with (NOLOCK)
	on b.Backup_ID = c.Backup_ID
order by Transfer_ID desc
end

 if @status ='Error'
begin
Select 
a.Transfer_ID, b.status as 'Backup_Status', c.BackupName, a.[status] as 'Transfer_Status'
, a.[Source],a.[Destination],a.startdate
, a.enddate, a.Message
from dblog.Backup_transfer_Job a with (NOLOCK)
join dblog.Backup_Jobs b with (NOLOCK)
	on a.Backup_Job_ID = b.Backup_Job_ID
join dblog.Backup_info c with (NOLOCK)
	on b.Backup_ID = c.Backup_ID
where a.Message NOT like '%1 file(s) copied.%' and LTRIM(RTRIM(message)) not like 'Log File%' and Message <> 'Transferred' and a.Status not in ('Obsoleted')
order by Transfer_ID desc
end