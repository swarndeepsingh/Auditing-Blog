create proc [DBLog].[getBackup_Info]
as
select
Backup_ID
, BackupName
, ServerName
, DBName
, BackupLocationID
, MirrorLocationID
, BackupType
, Enabled
, DR_Transfer
, CompressBackup
, UseInternalMirrorFunction
, LocalRetention_days
, RemoteRetention_days
from dblog.backup_info