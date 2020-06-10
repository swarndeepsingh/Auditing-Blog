create proc [DBLog].[usp_Backup_Configuration_Report]
as
select  a.BackupName, a.ServerName, a.DBName, b.LocationPath
, c.Locationpath, 
case a.BackupType when 'D' then 'Full - L0' when 'I' then 'Diff - L1' when 'L' then 'Tran = L2' end as 'BackupType'
, 
a.[Enabled], a.DR_Transfer, a.LocalRetention_days
, a.RemoteRetention_days, a.FrequencyName 
from dblog.backup_info a with (NOLOCK)
join dblog.Location_Details b with (NOLOCK)
	on a.BackupLocationID= b.LocationID
join dblog.Location_Details c with (NOLOCK)
	on a.MirrorLocationID = c.LocationID
where a.Enabled = 1
order by a.DBName, a.BackupType