create proc [DBLog].[usp_AddBackupConfiguration] (@backupName varchar(100), @DBName varchar(100), 
@backupLocationID int, @mirrorLocationID int, @backupType varchar(100), @drTransfer bit, 
@compressBackup bit, @localRetention int, @remoteRetention int, @backuptoolid varchar(3)=NULL)
as
set nocount on
if @backuptoolid is null set @backuptoolid = 'SQL'
insert into DBLOG.Backup_info (BackupName, DBName, BackupLocationID, MirrorLocationID, BackupType,
[Enabled], DR_Transfer, CompressBackup, LocalRetention_days, RemoteRetention_days, FrequencyName, UseInternalMirrorFunction, backuptoolid)
select @backupName, @DBName, @backupLocationID, @mirrorLocationID, @backupType, 1, @drTransfer, @compressBackup
, @localRetention, @remoteRetention
,case  when @backupType ='D' then 'Weekly_1'  when @backupType='I' then  'Daily_1' when @backupType='L' then 'Hourly_1' end
, 0, @backuptoolid
GO