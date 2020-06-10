create proc dblog.usp_Backup_Auto_Configure
as
declare @full varchar(20), @diff varchar(20), @log varchar(20)
declare @BackupLocaitonID int, @MirrorLocationID int
, @DR_Transfer bit, @CompressBackup bit, @LocalRetention_days int

, @RemoteRetention_days int, @backuptoolid varchar(100)

select @full = propertyvalue from dblog.MiscProperties where PropertyName= 'Backup_Full_Auto_Manual'
select @diff = propertyvalue from dblog.MiscProperties where PropertyName= 'Backup_Diff_Auto_Manual'
select @log = propertyvalue from dblog.MiscProperties where PropertyName= 'Backup_Log_Auto_Manual'

-- set default values based on master database
select @BackupLocaitonID=BackupLocationID
, @MirrorLocationID = MirrorLocationID, @DR_Transfer = DR_Transfer
, @CompressBackup = CompressBackup, @LocalRetention_days = LocalRetention_days
, @RemoteRetention_days = RemoteRetention_days, @backuptoolid = backuptoolid
 from dblog.dblog.Backup_info where DBName ='master' and BackupType ='D'


declare @delete_tables table
(
	DBName varchar(1024)
	, backuptype varchar(25)
)

--  Addition
-- FULL


if @full = 'Auto'
begin		
	INSERT INTO [DBLog].[DBLog].[Backup_info]
			   ([BackupName]
			   ,[ServerName]
			   ,[DBName]
			   ,[BackupLocationID]
			   ,[BackupLocation]
			   ,[MirrorLocationID]
			   ,[MirrorLocation]
			   ,[BackupType]
			   ,[Enabled]
			   ,[DR_Transfer]
			   ,[CompressBackup]
			   ,[UseInternalMirrorFunction]
			   ,[LocalRetention_days]
			   ,[RemoteRetention_days]
			   ,[FrequencyName]
			   ,[BackupToolID])
	select a.name + '_Full', @@SERVERNAME, name,@BackupLocaitonID,'tbd',@MirrorLocationID,NULL,'D',
	1,@DR_Transfer,@CompressBackup,0,@LocalRetention_days,@RemoteRetention_days,'Weekly_1', @backuptoolid  from sys.databases a
	where a.name not in (select DBName from dblog.backup_exceptions where backuptype = 'D')
	and a.name not in (select DBName from dblog.Backup_info with (NOLOCK) where BackupType = 'D')
	
	
	
	-- Deletion
	-- FULL
		insert into @delete_tables
		select distinct a.DBName, a.BackupType from dblog.Backup_info a with (NOLOCK) 
		left outer join sys.databases c 
			on a.DBName = c.name
		where c.name is null
		and a.Enabled=1	and a.BackupType = 'D'
				UNION
		select distinct a.DBName, a.BackupType from dblog.backup_exceptions a with (NOLOCK) 
		join dblog.Backup_info c 
			on a.DBName = c.DBName
			and a.backuptype = c.BackupType
		where c.Enabled=1	and a.BackupType = 'D'
	
end


	-- Diff
if @diff = 'Auto'
begin
	INSERT INTO [DBLog].[DBLog].[Backup_info]
			   ([BackupName]
			   ,[ServerName]
			   ,[DBName]
			   ,[BackupLocationID]
			   ,[BackupLocation]
			   ,[MirrorLocationID]
			   ,[MirrorLocation]
			   ,[BackupType]
			   ,[Enabled]
			   ,[DR_Transfer]
			   ,[CompressBackup]
			   ,[UseInternalMirrorFunction]
			   ,[LocalRetention_days]
			   ,[RemoteRetention_days]
			   ,[FrequencyName]
			   ,[BackupToolID])
	select a.name + '_Diff', @@SERVERNAME, name,@BackupLocaitonID,'tbd',@MirrorLocationID,NULL,'I',
	1,@DR_Transfer,@CompressBackup,0,@LocalRetention_days,@RemoteRetention_days,'Daily_1', @backuptoolid
	  from sys.databases a
	where a.name not in (select DBName from dblog.backup_exceptions where backuptype = 'I')
	and a.name not in (select DBName from dblog.Backup_info with (NOLOCK) where BackupType = 'I')
	
	
		-- Diff

			insert into @delete_tables
			select distinct a.DBName, a.BackupType from dblog.Backup_info a with (NOLOCK) 
			left outer join sys.databases c 
				on a.DBName = c.name
			where c.name is null
			and a.Enabled=1	and a.BackupType = 'I'
					UNION
			select distinct a.DBName, a.BackupType from dblog.backup_exceptions a with (NOLOCK) 
			join dblog.Backup_info c 
				on a.DBName = c.DBName
				and a.backuptype = c.BackupType
			where c.Enabled=1	and a.BackupType = 'I'



end


-- Log
if @log = 'Auto'
begin
	INSERT INTO [DBLog].[DBLog].[Backup_info]
			   ([BackupName]
			   ,[ServerName]
			   ,[DBName]
			   ,[BackupLocationID]
			   ,[BackupLocation]
			   ,[MirrorLocationID]
			   ,[MirrorLocation]
			   ,[BackupType]
			   ,[Enabled]
			   ,[DR_Transfer]
			   ,[CompressBackup]
			   ,[UseInternalMirrorFunction]
			   ,[LocalRetention_days]
			   ,[RemoteRetention_days]
			   ,[FrequencyName]
			   ,[BackupToolID])
	select a.name + '_Log', @@SERVERNAME, name,@BackupLocaitonID,'tbd',@MirrorLocationID,NULL,'L',
	1,@DR_Transfer,@CompressBackup,0,@LocalRetention_days,@RemoteRetention_days,'Hourly_1', @backuptoolid from sys.databases a
	where a.name not in (select DBName from dblog.backup_exceptions where backuptype = 'L')
	and a.name not in (select DBName from dblog.Backup_info with (NOLOCK) where BackupType = 'L')
	
	

		-- Log
			insert into @delete_tables
			select distinct a.DBName, a.BackupType from dblog.Backup_info a with (NOLOCK) 
			left outer join sys.databases c 
				on a.DBName = c.name
			where c.name is null
			and a.Enabled=1	and a.BackupType = 'L'
					UNION
			select distinct a.DBName, a.BackupType from dblog.backup_exceptions a with (NOLOCK) 
			join dblog.Backup_info c 
				on a.DBName = c.DBName
				and a.backuptype = c.BackupType
			where c.Enabled=1	and a.BackupType = 'L'
end







-- Finally update the list.
update  a
set a.Enabled = 0
FROM dblog.Backup_info a
join	@delete_tables b
	on a.DBName = b.DBName
	and a.BackupType = b.backuptype
	
	
	
-- Update the custome backup options other than daily and weekly


declare @frequencyname table (
frequencyname varchar(512)
, backuplocationid int
, mirrorlocationid int
, dr_transfer bit
, compressbackup bit
, locationretention_days int
, remoteretention_days int
,backuptoolid varchar(100)
)


insert into @frequencyname 
select distinct FrequencyName, max(BackupLocationID), max(MirrorLocationID), 1
, 1, max(LocalRetention_days), max(RemoteRetention_days), backuptoolid
 from dblog.backup_info where FrequencyName not in ('Daily_1','Weekly_1')
group by FrequencyName, backuptoolid

/*
select b.*, a.* from sys.databases a
left outer join dblog.Backup_info b
	on a.name = b.DBName
where b.FrequencyName not in (select FrequencyName from @frequencyname)
*/
declare @tempList table
(
dbname varchar(255), freq varchar(255)
, backuplocationid int
, mirrorlocationid int
, dr_transfer bit
, compressbackup bit
, locationretention_days int
, remoteretention_days int
, backuptoolid varchar(100)
)

insert into @tempList
select distinct a.dbname , b.frequencyname, b.backuplocationid, b.mirrorlocationid, b.dr_transfer , b.compressbackup
, b.locationretention_days,  b.remoteretention_days, b.backuptoolid
from dblog.backup_info a, @frequencyname b
where a.dbname not in ('tempdb','model','msdb','master', 'DBLOG')
and Enabled= 1

insert into dblog.Backup_info ([BackupName]
           ,[ServerName]
           ,[DBName]
           ,[BackupLocationID]
           ,[BackupLocation]
           ,[MirrorLocationID]
           ,[MirrorLocation]
           ,[BackupType]
           ,[Enabled]
           ,[DR_Transfer]
           ,[CompressBackup]
           ,[UseInternalMirrorFunction]
           ,[LocalRetention_days]
           ,[RemoteRetention_days]
           ,[FrequencyName]
           ,[BackupToolID]
           ,[TransferMethod])
select a.dbname +'_' + a.freq, @@SERVERNAME, a.dbname, a.backuplocationid, 'tbd', 
a.mirrorlocationid, NULL, 'D', 1, a.dr_transfer, a.compressbackup, 0, a.locationretention_days, a.remoteretention_days
, a.freq, a.backuptoolid, 'SQL'
 from @tempList a
left outer join dblog.dblog.Backup_info  b
	on a.DBName = b.dbname
	and a.freq = b.FrequencyName
where b.DBName is null 
order by freq


GO