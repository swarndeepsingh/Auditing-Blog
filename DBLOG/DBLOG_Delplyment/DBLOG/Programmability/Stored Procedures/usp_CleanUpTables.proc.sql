CREATE proc [DBLog].[usp_CleanUpTables]
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