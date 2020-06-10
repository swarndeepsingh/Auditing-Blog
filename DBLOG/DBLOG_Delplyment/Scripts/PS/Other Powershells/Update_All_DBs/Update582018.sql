

--Alter
ALTER table [DBLog].[Backup_info] ADD
    [TransferMethod]            VARCHAR (50)  NOT NULL DEFAULT ('ROBOCOPY')
GO

-- Create
if (object_id('dbo.bits_transfer_job') is null)
BEGIN
CREATE TABLE [DBLog].[bits_transfer_job] (
    [Transfer_ID]       INT            NOT NULL,
    [BitsJobID]         VARCHAR (256)  NOT NULL,
    [JobStatus]         VARCHAR (50)   NULL,
    [OwnerAccount]      VARCHAR (256)  NULL,
    [HostName]          VARCHAR (256)  NULL,
    [ErrorCount]        INT            NULL,
    [ErrorContext]      VARCHAR (1024) NULL,
    [ErrorCondition]    VARCHAR (2048) NULL,
    [BytesTotal]        BIGINT         NULL,
    [BytesTransferred]  BIGINT         NULL,
    [TransferSpeed]     AS             ([bytestransferred]/case when datediff(second,[starttime],[laststatustime])=(0) then (1) else datediff(second,[starttime],[laststatustime]) end),
    [TransferSpeedGBpH] AS             ((((((([bytestransferred]/case when datediff(second,[starttime],[laststatustime])=(0) then (1) else datediff(second,[starttime],[laststatustime]) end)*(1.00000))/(1024))/(1024))/(1024))*(60))*(60)),
    [Files]             INT            NULL,
    [FilesTransferred]  INT            NULL,
    [StartTime]         DATETIME       NULL,
    [TransferredTime]   DATETIME       NULL,
    [CompletedTime]     DATETIME       NULL,
    [LastStatusTime]    DATETIME       NOT NULL
)
END
GO


ALTER TABLE [DBLog].[bits_transfer_job]
    ADD CONSTRAINT [PK_bits_transfer_job] PRIMARY KEY CLUSTERED ([Transfer_ID] ASC) WITH (FILLFACTOR = 90, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);
	
GO	


--Create
if (object_id('dbo.bits_transfer_properties') is null)
BEGIN
	CREATE TABLE [DBLog].[bits_transfer_properties] (
		[PropertyID] INT           IDENTITY (1, 1) NOT NULL,
		[property]   VARCHAR (50)  NOT NULL,
		[property1]  VARCHAR (100) NOT NULL,
		[Value]      INT           NOT NULL
	)
END;
GO


-- Update
alter proc [DBLog].[usp_Backup_Auto_Configure]
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

insert into dblog.Backup_info
(
[BackupName]
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
           )
select a.dbname +'_' + a.freq, @@SERVERNAME, a.dbname, a.backuplocationid, 'tbd', 
a.mirrorlocationid, NULL, 'D', 1, a.dr_transfer, a.compressbackup, 0, a.locationretention_days, a.remoteretention_days
, a.freq, a.backuptoolid
 from @tempList a
left outer join dblog.dblog.Backup_info  b
	on a.DBName = b.dbname
	and a.freq = b.FrequencyName
where b.DBName is null 
order by freq

GO



-- Update
alter PROC [DBLog].[usp_Backup_Transfer_Files]
as
declare @transferid int, @source varchar(8000), @destination varchar(8000), @sqltext varchar(8000), @sourcelocationid int, @destinationlocationid int
declare @message varchar(8000), @source_path varchar(8000), @source_file varchar(8000)
declare @transfermethod varchar(50), @msg varchar(1024)
declare @exitcode int
select top 1 @transferid = transfer_id, @source=[Source], @destination = Destination
, @sourcelocationid = sourcelocationid, @destinationlocationid = destinationlocationid
, @transfermethod = transfermethod
from DBLog.Backup_transfer_Job btj with (NOLOCK)
join dblog.Backup_info bi
	on bi.backup_id = btj.backup_id
where Status = 'Pending' and startdate is NULL
order by Backup_Job_ID asc

if (@transfermethod <> 'robocopy')
BEGIN
	select @msg = 'Please use ' + @transfermethod + ' method to transfer files, robocopy will exit now'
	print @msg
	return
END

-- Separate file name and path from full path
-- Extracting File Name
select @source_file= Reverse(Left(Reverse(@source),Charindex('\',Reverse(@source))-1)) 

--Extracting the path only
select @source_path = substring(@source,1,len(@source)-CHARINDEX('\',reverse(@source)))



exec [dblog].[usp_MapLocation] @sourcelocationid, '' 
exec [dblog].[usp_MapLocation] @destinationlocationid, '' 


update dblog.Backup_transfer_Job 
set startdate = GETDATE(), status='Copying'
where transfer_id = @transferid

create table #error
(
error varchar(8000)
)
create table #xp_cmdshell
(
name varchar(200),
minval varchar(1),
maxval varchar(1),
configval varchar(1),
runval varchar(1)
)

create table #ShowAdvancedOptions
(
name varchar(200),
minval varchar(1),
maxval varchar(1),
configval varchar(1),
runval varchar(1)
)

insert into #ShowAdvancedOptions
EXEC sp_configure 'Show Advanced Options'
if (select configval from #ShowAdvancedOptions) = 0
begin
EXEC sp_configure 'Show Advanced Options', 1
reconfigure with override		
end

insert into #XP_cmdshell
EXEC sp_configure 'xp_cmdshell'
if (select configval from #XP_cmdshell) = 0
begin
EXEC sp_configure 'xp_cmdshell', 1
reconfigure with override

end	
-- set @sqltext = 'master.dbo.xp_cmdshell ''COPY "' + @source + '" "' + @destination + '"'''

-- Upgraded from regular copy to robocopy for better command over file transfers
set @sqltext = 'robocopy "' + @source_path + '" "' + @destination + '" ' + @source_file + ' /log:"' + @source_path +'\'+ @source_file+ '_transfer_log.log" ' +' /R:5 /W:180  /tee /np /Copy:DT'

EXEC @exitcode = master.dbo.xp_cmdshell @sqltext, 'NO_OUTPUT' 

set @message = case CONVERT(varchar, @exitcode) when 0 then 'No Change' when 1 then 'Transferred' when 4 then 'Mimatched Files were detected - Refer to Log File' when 8 then 'Copy Failed' when 16 then 'Serious Error - Refer to Log File' else 'Failed' End


-- select top 1 @message = error from #error where error is not NULL

update dblog.Backup_transfer_Job 
set [message] = @message, enddate = GETDATE(), Status = 'Completed'
where transfer_id = @transferid

print @message
-- EXEC sp_configure 'xp_cmdshell', 0
-- reconfigure with override

-- EXEC sp_configure 'Show Advanced Options', 0
-- reconfigure with override


exec [dblog].[usp_DeleteMapLocation] @sourcelocationid
exec [dblog].[usp_DeleteMapLocation] @destinationlocationid
GO


alter PROC [DBLog].[usp_Backup_Transfer_Files_DiffOnly]
as
declare @transferid int, @source varchar(8000), @destination varchar(8000), @sqltext varchar(8000), @sourcelocationid int, @destinationlocationid int
declare @message varchar(8000), @source_path varchar(8000), @source_file varchar(8000)
declare @exitcode int
declare @transfermethod varchar(50), @msg varchar(1024)


select top 1 @transferid = transfer_id, @source=[Source], @destination = Destination
, @sourcelocationid = sourcelocationid, @destinationlocationid = destinationlocationid
, @transfermethod = transfermethod
from DBLog.Backup_transfer_Job btj with (NOLOCK)
join dblog.Backup_info bi
	on bi.backup_id = btj.backup_id
	and bi.BackupType = 'I'
where Status = 'Pending' and startdate is NULL
order by Backup_Job_ID asc

if (@transfermethod <> 'robocopy')
BEGIN
	select @msg = 'Please use ' + @transfermethod + ' method to transfer files, robocopy will exit now'
	print @msg
	return
END


-- Separate file name and path from full path
-- Extracting File Name
select @source_file= Reverse(Left(Reverse(@source),Charindex('\',Reverse(@source))-1)) 

--Extracting the path only
select @source_path = substring(@source,1,len(@source)-CHARINDEX('\',reverse(@source)))



exec [dblog].[usp_MapLocation] @sourcelocationid, '' 
exec [dblog].[usp_MapLocation] @destinationlocationid, '' 


update dblog.Backup_transfer_Job 
set startdate = GETDATE(), status='Copying'
where transfer_id = @transferid

create table #error
(
error varchar(8000)
)
create table #xp_cmdshell
(
name varchar(200),
minval varchar(1),
maxval varchar(1),
configval varchar(1),
runval varchar(1)
)

create table #ShowAdvancedOptions
(
name varchar(200),
minval varchar(1),
maxval varchar(1),
configval varchar(1),
runval varchar(1)
)

insert into #ShowAdvancedOptions
EXEC sp_configure 'Show Advanced Options'
if (select configval from #ShowAdvancedOptions) = 0
begin
EXEC sp_configure 'Show Advanced Options', 1
reconfigure with override		
end

insert into #XP_cmdshell
EXEC sp_configure 'xp_cmdshell'
if (select configval from #XP_cmdshell) = 0
begin
EXEC sp_configure 'xp_cmdshell', 1
reconfigure with override

end	
-- set @sqltext = 'master.dbo.xp_cmdshell ''COPY "' + @source + '" "' + @destination + '"'''

-- Upgraded from regular copy to robocopy for better command over file transfers
set @sqltext = 'robocopy "' + @source_path + '" "' + @destination + '" ' + @source_file + ' /log:"' + @source_path +'\'+ @source_file+ '_transfer_log.log" ' +' /R:5 /W:180  /tee /np /Copy:DT'

EXEC @exitcode = master.dbo.xp_cmdshell @sqltext, 'NO_OUTPUT' 

set @message = case CONVERT(varchar, @exitcode) when 0 then 'No Change' when 1 then 'Transferred' when 4 then 'Mimatched Files were detected - Refer to Log File' when 8 then 'Copy Failed' when 16 then 'Serious Error - Refer to Log File' else 'Failed' End


-- select top 1 @message = error from #error where error is not NULL

update dblog.Backup_transfer_Job 
set [message] = @message, enddate = GETDATE(), Status = 'Completed'
where transfer_id = @transferid

print @message
-- EXEC sp_configure 'xp_cmdshell', 0
-- reconfigure with override

-- EXEC sp_configure 'Show Advanced Options', 0
-- reconfigure with override


exec [dblog].[usp_DeleteMapLocation] @sourcelocationid
exec [dblog].[usp_DeleteMapLocation] @destinationlocationid

Go




if not exists (select 1 from [DBLog].[MiscProperties] where propertyname ='backup_obsolete_log_retention')
INSERT [DBLog].[MiscProperties] ([PropertyName], [Propertyvalue]) VALUES (N'backup_obsolete_log_retention', N'730')
GO


if not exists (select 1 from [DBLog].[MiscProperties] where propertyname ='backup_completed_log_retention')
INSERT [DBLog].[MiscProperties] ([PropertyName], [Propertyvalue]) VALUES (N'backup_completed_log_retention', N'730')
GO



-- Update
alter proc [DBLog].[usp_CleanUpTables]
@alertToBeDeleted int = 15
, @backupCompletedToBeDeleted int = 730
, @backupsObsoletedToBeDeleted int = 730

as

declare @obsbackretention int
declare @compbackretention int

/*
****************************************************************************************************
**		File: usp_CleanUpTables.sql
**		Desc: (1) Cleans DBLOG Tables (2)Archives DB Usage Data (3) Shrinks DB Files.
**
**		Called by: SQL Agent Job --> DBLOG.CleanUpTables
**              
**		Auth: Swarndeep Singh
**		Date: 2013.02.06
******************************************************************************************************
** Change History
*******************************************************************************************************
 Date:		Author:		Description:
2015.08.05	DDavis		Added DBUsage Archive table
2016.01.29	DDavis		Commented out DBUsage Archive section
2016.05.26	SSINGH		The Backup Logs deletion can be be customized (Change #3)
*******************************************************************************************************
*/

declare @backupJobs table
(backup_Job_ID int)

-- BEgin Change #3
select @obsbackretention = Propertyvalue from dblog.dblog.MiscProperties where PropertyName = 'backup_obsolete_log_retention'
select @compbackretention = propertyvalue from dblog.dblog.MiscProperties where PropertyName = 'backup_completed_log_retention'
select @backupCompletedToBeDeleted = ISNULL(@compbackretention, @backupCompletedToBeDeleted)
select @backupsObsoletedToBeDeleted = ISNULL(@obsbackretention, @backupsObsoletedToBeDeleted)
-- END CHnage # 3
/* Delete Alerts */
delete from dblog.Alert_Events where Alert_Status in ('Closed','Close') and DATEDIFF(DAY, Last_Sent, getdate()) > @alertToBeDeleted and Alert_Subject not like '%Auditable%'

delete from dblog.Alert_Events where Alert_Status in ('Closed','Close') and DATEDIFF(DAY, Last_Sent, getdate()) > 180 and Alert_Subject like '%Auditable%'

/* Get all backup jobs per filter criteria */
/* Get completed backup jobs */
insert into @backupJobs
select backup_job_id from dblog.backup_jobs with (NOLOCK)
where [status] in ('Completed', 'Complete')
and datediff(DAY,retainuntil_local, getdate()) > @backupCompletedToBeDeleted 

/* Get Cancelled backup jobs */
insert into @backupJobs
select backup_job_id from dblog.backup_jobs with (NOLOCK)
where [status] in ('Cancelled')
and datediff(DAY,Backup_Start_Time, getdate()) > @backupsObsoletedToBeDeleted 

/* Get Cancelled backup jobs */
insert into @backupJobs
select backup_job_id from dblog.backup_jobs with (NOLOCK)
where retainUntil_local is null
and datediff(DAY,Backup_Start_Time, getdate()) > @backupCompletedToBeDeleted 


/* Delete backup delete files logs */
delete from dblog.Backup_Delete_Files
where Backup_Job_ID in (select Backup_Job_ID from @backupJobs)

/* Delete transfer logs */
delete from dblog.Backup_transfer_Job
where Backup_Job_ID in (select Backup_Job_ID from @backupJobs)

/* Delete backup jobs */
delete from dblog.Backup_Jobs
where Backup_Job_ID in (select Backup_Job_ID from @backupJobs)


/* Move Usage data to Archive table*/
	-- Insert into Archival Table first
	--	INSERT INTO DBLog.DBUsage_Archive
    --       (CollectionDate
   --        ,Servername
 --          ,DatabaseName
 --          ,table_name
 --          ,row_count
 --          ,reserved_size
 --          ,space_used)
 --    SELECT CollectionDate,
	--		  Servername,
	--		  DatabaseName,
	--		  table_name,
	--		  row_count,
	--		  reserved_size,
	--		  space_used
	--FROM DBLog.DBLog.DBUsage
	--WHERE DatabaseName NOT IN ('Master','Model','MSDB','[MDW]','[DBLOG]','TempDB','MDW','DBLOG','distribution')


/* Delete DBUsage */
--truncate table dblog.DBUsage

/* Delete DBUsage_Archive keep 90 days*/
--delete from DBLog.DBUsage_Archive
--where datediff(DAY,CollectionDate, getdate()) > 91

/* Delete audit data */
delete from dblog.Trace_AuditTSQL_Archive
where datediff(DAY,StartTime, getdate()) > 365

delete from dblog.Trace_Failed_Login_Archive
where datediff(DAY,StartTime, getdate()) > 365


/* Shrink database */

declare @name varchar(512)
declare  shrinkFiles cursor
for select name from DBLOG.sys.database_files

open shrinkFiles
fetch shrinkFiles into @name

while @@FETCH_STATUS = 0
begin
	DBCC SHRINKFILE ( @name, 1)
	fetch shrinkFiles into @name
end
close shrinkFiles
deallocate shrinkFiles



GO





