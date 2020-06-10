USE DBLOG
GO

if not exists(select 1 from [DBLog].[Errors] where ErrorID = '8701')
	INSERT [DBLog].[Errors] ([ErrorID], [ErrorDescription], [Importance]) VALUES (N'8701', N'Open Items', N'Med')
if not exists(select 1 from [DBLog].[Errors] where ErrorID = '8801')
	INSERT [DBLog].[Errors] ([ErrorID], [ErrorDescription], [Importance]) VALUES (N'8801', N'Backup Failed to Take', N'High')
if not exists(select 1 from [DBLog].[Errors] where ErrorID = '8802')
	INSERT [DBLog].[Errors] ([ErrorID], [ErrorDescription], [Importance]) VALUES (N'8802', N'Backup Stuck', N'Med')
if not exists(select 1 from [DBLog].[Errors] where ErrorID = '8901')
	INSERT [DBLog].[Errors] ([ErrorID], [ErrorDescription], [Importance]) VALUES (N'8901', N'Backup Failed to Transfer', N'High')
if not exists(select 1 from [DBLog].[Errors] where ErrorID = '8902')
	INSERT [DBLog].[Errors] ([ErrorID], [ErrorDescription], [Importance]) VALUES (N'8902', N'Backup Transfer Stuck', N'Med')
if not exists(select 1 from [DBLog].[Errors] where ErrorID = '8702')
	INSERT [DBLog].[Errors] ([ErrorID], [ErrorDescription], [Importance]) VALUES (N'8702', N'SQL Agent Job Failed', N'High')
if not exists(select 1 from [DBLog].[Errors] where ErrorID = '8703')
	INSERT [DBLog].[Errors] ([ErrorID], [ErrorDescription], [Importance]) VALUES (N'8703', N'Audit Alert', N'High')
if not exists(select 1 from [DBLog].[Errors] where ErrorID = '8704')
	INSERT [DBLog].[Errors] ([ErrorID], [ErrorDescription], [Importance]) VALUES (N'8704', N'Audit_Alert_Social', N'High')
if not exists(select 1 from [DBLog].[Errors] where ErrorID = '8705')
	INSERT [DBLog].[Errors] ([ErrorID], [ErrorDescription], [Importance]) VALUES (N'8705', N'Audit_Alert_TIN', N'High')
if not exists(select 1 from [DBLog].[Errors] where ErrorID = '8601')
	INSERT [DBLog].[Errors] ([ErrorID], [ErrorDescription], [Importance]) VALUES (N'8601', N'Full_Backup_Config', N'High')
if not exists(select 1 from [DBLog].[Errors] where ErrorID = '8602')
	INSERT [DBLog].[Errors] ([ErrorID], [ErrorDescription], [Importance]) VALUES (N'8602', N'Diff_Backup_Config', N'High')
if not exists(select 1 from [DBLog].[Errors] where ErrorID = '8603')
	INSERT [DBLog].[Errors] ([ErrorID], [ErrorDescription], [Importance]) VALUES (N'8603', N'Log_Backup_Config', N'High')


if not exists(select 1 from [DBLog].[Errors] where ErrorID = '8604')
	INSERT [DBLog].[Errors] ([ErrorID], [ErrorDescription], [Importance]) VALUES (N'8604', N'Missing_Full_Backup', N'High')

if not exists(select 1 from [DBLog].[Errors] where ErrorID = '8605')
	INSERT [DBLog].[Errors] ([ErrorID], [ErrorDescription], [Importance]) VALUES (N'8605', N'Missing_Diff_Backup', N'High')

if not exists(select 1 from [DBLog].[Errors] where ErrorID = '8606')
	INSERT [DBLog].[Errors] ([ErrorID], [ErrorDescription], [Importance]) VALUES (N'8606', N'Database_Blocking_Open_Tx', N'High')



	/****** Object:  Table [DBLog].[Error_Alert]    Script Date: 02/04/2012 18:45:28 ******/




--		a. Trace_Jobs
		if not exists (select 1 from DBLOG.Trace_Jobs)
		begin
			INSERT [DBLog].[Trace_Jobs] ([Tracename], [SPName], [Active], [CreateDate]) VALUES (N'AuditFailedLogin', N'[DBLog].usp_AuditFailedLogins', 1, getdate())
			INSERT [DBLog].[Trace_Jobs] ([Tracename], [SPName], [Active], [CreateDate]) VALUES (N'AuditTSQL', N'[DBLog].usp_AuditTSQL', 1, getdate())
			INSERT [DBLog].[Trace_Jobs] ([Tracename], [SPName], [Active], [CreateDate]) VALUES (N'Orphaned', N'Orphaned', 0, getdate())
		end


-- 		b. Trace_Exceptions
		if not exists (select 1 from DBLOG.[Trace_Exceptions])
		begin
			INSERT [DBLog].[Trace_Exceptions] ([TraceName], [ColumnNumber], [ColumnName], [ColumnValue], [LogicalOperator], [ComparisonOperator]) VALUES (N'AuditTSQL', 6, N'NT User Name', N'cluster-svc', 0, 1)
			INSERT [DBLog].[Trace_Exceptions] ([TraceName], [ColumnNumber], [ColumnName], [ColumnValue], [LogicalOperator], [ComparisonOperator]) VALUES (N'AuditTSQL', 6, N'NT User Name', N'app-svc', 0, 1)
			INSERT [DBLog].[Trace_Exceptions] ([TraceName], [ColumnNumber], [ColumnName], [ColumnValue], [LogicalOperator], [ComparisonOperator]) VALUES (N'AuditTSQL', 35, N'DB Name', N'distribution', 0, 1)
		end

--		c. Trace_Properties


		if not exists (select 1 from DBLOG.[Trace_Properties])
		begin		
			INSERT [DBLog].[Trace_Properties] ([TraceName], [PropertyName], [PropertyValue], [User_Configurable], [Description]) VALUES (N'AuditFailedLogin', N'FolderPath', N'D:\tracefile\login_trace', 1, N'Folder to store the traces')
			INSERT [DBLog].[Trace_Properties] ([TraceName], [PropertyName], [PropertyValue], [User_Configurable], [Description]) VALUES (N'AuditFailedLogin', N'Interval', N'600', 1, N'Number of Minutes to recycle the traces, if status is set to stopped then this property is ignored')
			INSERT [DBLog].[Trace_Properties] ([TraceName], [PropertyName], [PropertyValue], [User_Configurable], [Description]) VALUES (N'AuditFailedLogin', N'LastImported', N'Dec 20 2011  8:00AM', 0, N'Last Date when Trace file imported into table')
			INSERT [DBLog].[Trace_Properties] ([TraceName], [PropertyName], [PropertyValue], [User_Configurable], [Description]) VALUES (N'AuditFailedLogin', N'Status', N'Stop', 1, N'To stop the Trace set this value to Stop else set to Reset')
			INSERT [DBLog].[Trace_Properties] ([TraceName], [PropertyName], [PropertyValue], [User_Configurable], [Description]) VALUES (N'AuditTSQL', N'FolderPath', N'D:\tracefile\AuditTSQL', 1, N'folder to store the traces')
			INSERT [DBLog].[Trace_Properties] ([TraceName], [PropertyName], [PropertyValue], [User_Configurable], [Description]) VALUES (N'AuditTSQL', N'Interval', N'600', 1, N'Number of Minutes to recycle the traces, if status is set to stopped...')
			INSERT [DBLog].[Trace_Properties] ([TraceName], [PropertyName], [PropertyValue], [User_Configurable], [Description]) VALUES (N'AuditTSQL', N'LastImported', N'Dec 20 2011  8:00AM', 0, N'NA')
			INSERT [DBLog].[Trace_Properties] ([TraceName], [PropertyName], [PropertyValue], [User_Configurable], [Description]) VALUES (N'AuditTSQL', N'Status', N'Stop', 1, N'To stop the trace')
		end

		GO


-- Alert Definitions

declare @version varchar(20)

select @version=cast(SERVERPROPERTY('productversion') as varchar(10))
print @version
if @version like '9%' or @version like '8%'
begin
	print 'Version Not Compatible for Merge Statement'
	return
end
else if @version not like '9%' and @version not like '8%'
begin
DECLARE @alert_definitions TABLE(
	[AlertName] [varchar](50) NOT NULL,
	[Enabled] [bit] NOT NULL,
	[AlertType] [varchar](500) NOT NULL,
	[AlertQuery_Type] [varchar](50) NOT NULL,
	[AlertTable] [varchar](500) NULL,
	[AlertColumn] [varchar](500) NULL,
	[AlertQuery] [varchar](max) NOT NULL,
	[AlertMethod] [varchar](50) NULL,
	[EmailProfile] [varchar](500) NULL,
	[AlertRecipients] [varchar](8000) NULL,
	[AlertSubject_Query] [varchar](2000) NULL,
	[AlertBody_Query] [varchar](2000) NULL,
	[AlertGap_minutes] [int] NULL,
	[MaxAlerts] [int] NULL
)

INSERT INTO @alert_definitions
values 
(N'Backup_Failed', 1, N'Error', N'Full-Query', N'dblog.Backup_all_info' 
, N'Backup_job_id' 
, N'select a.Backup_job_id from dblog.Backup_Jobs a with (NOLOCK) join dblog.Backup_info b with (NOLOCK) 	on a.Backup_ID = b.Backup_ID where a.status not in (''Completed'', ''Started'',''Cancelled'')'
, N'Email', N'DBAMail', N'swarndeep.singh@ebix.com'
, N'select @sub= ''Backup '' + status + '' '' + BackupName + '' as on '' + cast (Backup_Start_Time as varchar(100)) from ' , N'select  @body = ''<font face="verdana" size = "2"><p><font color = "red"><center><H2>Attention</H2></center></font></p><BR><BR><p>Backup <B>"'' + BackupName + ''"</B> is <B>'' + Status + ''</B> </p><P><B>ServerName:</B> '' + Servername + ''</p><p><B>DatabaseName:</B> '' + DBName + ''</p><p><B>BackupType:</B> '' + case BackupType when ''D'' then ''Full(L0)'' when ''I'' then ''Differential (L1)'' else ''Transaction Log'' End + ''</p> <p><B>Reference: </B> DBLOG.Backup_jobs.Backup_job_id='' + cast(backup_job_id as varchar(30)) + ''</p> <BR> Thanks <BR> Database Alert Agent<BR> <I>DO NOT REPLY to this e-mail address, contact DBA for '' + ServerName +''.</I></font>'' from', 480, 1)
-- next
-- union
INSERT INTO @alert_definitions
values (  N'Backup_Stuck', 1, N'Warning', N'Full-Query', N'dblog.backup_all_info', N'Backup_job_id'
, N'Select Backup_Job_ID from dblog.backup_jobs with (NOLOCK) where status =''Started'' and DATEDIFF(Hour,Backup_Start_Time,GETDATE()) > 24'
, N'Email', N'DBAMail', 'swarndeep.singh@ebix.com'
, N'select @sub= ''Backup Stuck:''  + BackupName + '' as on '' + cast(Backup_Start_Time as varchar(100)) from'
, N'select @body = ''<font face="verdana" size = "2"><p><font color = "red"><center><H2>Attention</H2></center></font></p><BR><BR><p>Backup <B>"'' + BackupName + ''"</B> Seems like stuck <B></B> </p><P><B>ServerName:</B> '' + Servername + ''</p><p><B>DatabaseName:</B> '' + DBName + ''</p><p><B>BackupType:</B> '' + case BackupType when ''D'' then ''Full(L0)'' when ''I'' then ''Differential (L1)'' else ''Transaction Log'' End + ''</p> <p><B>Reference:</B> DBLOG.Backup_jobs.Backup_job_id='' + cast(backup_job_id as varchar(30)) + '' </p><BR> Thanks <BR> Database Alert Agent<BR> <I>DO NOT REPLY to this e-mail address, contact DBA for '' + ServerName +''.</I></font>'' from'
, 480, 1)
-- union
-- next
INSERT INTO @alert_definitions
values ( N'Transfer_Failed', 1, N'Error',  N'Full-Query', N'dblog.backup_all_info', N'Backup_job_id', N'select backup_job_id from dblog.backup_all_info with (NOLOCK) where ((LTRIM(RTRIM(message)) <> ''1 file(s) copied.'' and ((LTRIM(RTRIM(message)) not like ''Log File%'' and Message <> ''Transferred'') and transferstatus <> ''Obsoleted'' )  and source is not null))', N'Email', N'DBAMail',  N'swarndeep.singh@ebix.com', N'select @sub= ''Backup Transfer Failed:''  + BackupName + '' as on '' + cast(startdate as varchar(100)) from'
, N'select @body = ''<font face="verdana" size = "2"><p><font color = "red"><center><H2>Attention</H2></center></font></p><BR><BR><p>Backup Transfer <B>"'' + BackupName + ''"</B> Failed to Transfer <B></B> </p><P><B>ServerName:</B> '' + Servername + ''</p><p><B>DatabaseName:</B> '' + DBName + ''</p><p><B>BackupType:</B> '' + case BackupType when ''D'' then ''Full(L0)'' when ''I'' then ''Differential (L1)'' else ''Transaction Log'' End + ''</p><p><b>Source Location: </b>'' + Source + ''<p><b>Destination Location: </b>'' + Destination + ''</p><p><b>Reference:</b> DBLOG.Backup_Transfer_job.transfer_id='' + cast(Transfer_id as varchar(30))+ ''</p> <BR> Thanks <BR> Database Alert Agent<BR> <I>DO NOT REPLY to this e-mail address, contact DBA for '' + ServerName +''.</I></font>'' from', 480, 1)

--union
INSERT INTO @alert_definitions
values (  N'Transfer_Stuck', 1, N'Warning', N'Full-Query', N'dblog.backup_all_info', N'backup_job_id', N'select backup_job_id from dblog.backup_all_info with (NOLOCK) where transferstatus =''Pending'' and DATEDIFF(hour,startdate,getdate()) > 24', N'Email', N'DBAMail',  N'swarndeep.singh@ebix.com', N'select @sub= ''Backup Transfer Stuck:''  + BackupName + '' as on '' + cast(startdate as varchar(100)) from'
, N'select @body = ''<font face="verdana" size = "2"><p><font color = "red"><center><H2>Attention</H2></center></font></p><BR><BR><p>Backup Transfer <B>"'' + BackupName + ''"</B> seems to be stuck. <B></B> </p><P><B>ServerName:</B> '' + Servername + ''</p><p><B>DatabaseName:</B> '' + DBName + ''</p><p><B>BackupType:</B> '' + case BackupType when ''D'' then ''Full(L0)'' when ''I'' then ''Differential (L1)'' else ''Transaction Log'' End + ''</p><p><b>Source Location: </b>'' + Source + ''<p><b>Destination Location: </b>'' + Destination + ''</p><p><b>Reference:</b> DBLOG.Backup_Transfer_job.transfer_id='' + cast(Transfer_id as varchar(30))+ ''</p> <BR> Thanks <BR> Database Alert Agent<BR> <I>DO NOT REPLY to this e-mail address, contact DBA for '' + ServerName +''.</I></font>'' from', 480,1)

-- next
-- union
INSERT INTO @alert_definitions
values (  N'Open_Items', 1, N'Information', N'Full-Query', N'dblog.alert_events where alert_status =''Open'' --', N'alert_event_id'
, N'select top 1 alert_event_id from dblog.alert_events with (NOLOCK) where alert_status =''Open'''
, N'Email', N'DBAMail',  N'swarndeep.singh@ebix.com', 
N'select  @sub=''Open Alerts: (''  + cast(COUNT(alert_event_id) as varchar(10)) + '') as on '' + cast(GETDATE() as varchar(100)) from', 
N'select  @body=''<font face="verdana" size = "2"><p><font color = "red"><center><H2>Attention</H2></center></font></p><BR><BR><p>There are unresolved Open Alerts, which need attention. </p><P><B>ServerName:</B> '' + @@servername + ''</p><Table border ="1">     
<tr><th>List of Open Alerts</th>''  + CAST((select td=alert_subject  
from dblog.alert_events with(NOLOCK)where Alert_Status not IN (''Close'',''Closed'',''Suspended'',''Resolved'')      
for XML PATH (''tr''), TYPE) as NVARCHAR(MAX))    
+N''</Table>''-- '
, 560, 1);


-- This is Audit Alert
INSERT INTO @alert_definitions
values ( N'Audit_Alert_Star', 1, N'Information',  N'Full-Query', N'dblog.Trace_AuditTSQL_Archive', N'AuditTSQL_ID', N'select AuditTSQL_ID from dblog.Trace_AuditTSQL_Archive with (NOLOCK) where  TEXTDATA LIKE ''%*%''', N'Email', N'DBAMail',  N'swarndeep.singh@ebix.com', N'select @sub= ''Auditable Keywords Detected in query, Audit ID :''  + cast(AuditTSQL_ID as varchar(30)) + '' as on '' + cast(starttime as varchar(100)) from'
, N'select @body = ''<font face="verdana" size = "2"><p><font color = "red"><center><H2>Attention</H2></center></font></p><BR><BR><p>Audit for user ID<B> "'' + LoginName + ''"</B> Failed. <B></B> </p><P><B>ServerName:</B> '' + Servername + ''</p><p><B>DatabaseName:</B> '' + DBName + ''</p><p><B>Text:</B> '' + TextData + ''</p><p><b>Host Name: </b>'' + HostName + ''<p><b>SPID: </b>'' + SPID + ''</p><p><b>Reference:</b> DBLOG.Trace_AuditTSQL_Archive.AuditTSQL_ID='' + cast(AuditTSQL_ID as varchar(30))+ ''</p> <BR> Thanks <BR> Database Alert Agent<BR> <I>DO NOT REPLY to this e-mail address, contact DBA for '' + ServerName +''.</I></font>'' from', 480, 1)





-- End Audit Alert


-- This is Audit Alert
INSERT INTO @alert_definitions
values ( N'Audit_Alert_Social', 1, N'Information',  N'Full-Query', N'dblog.Trace_AuditTSQL_Archive', N'AuditTSQL_ID', N'select AuditTSQL_ID from dblog.Trace_AuditTSQL_Archive with (NOLOCK) where  TEXTDATA LIKE ''%Social%''', N'Email', N'DBAMail',  N'swarndeep.singh@ebix.com', N'select @sub= ''Auditable Keywords Detected in query, Audit ID :''  + cast(AuditTSQL_ID as varchar(30)) + '' as on '' + cast(starttime as varchar(100)) from'
, N'select @body = ''<font face="verdana" size = "2"><p><font color = "red"><center><H2>Attention</H2></center></font></p><BR><BR><p>Audit for user ID<B> "'' + LoginName + ''"</B> Failed. <B></B> </p><P><B>ServerName:</B> '' + Servername + ''</p><p><B>DatabaseName:</B> '' + DBName + ''</p><p><B>Text:</B> '' + TextData + ''</p><p><b>Host Name: </b>'' + HostName + ''<p><b>SPID: </b>'' + SPID + ''</p><p><b>Reference:</b> DBLOG.Trace_AuditTSQL_Archive.AuditTSQL_ID='' + cast(AuditTSQL_ID as varchar(30))+ ''</p> <BR> Thanks <BR> Database Alert Agent<BR> <I>DO NOT REPLY to this e-mail address, contact DBA for '' + ServerName +''.</I></font>'' from', 480, 1)





-- End Audit Alert

-- This is Audit Alert
INSERT INTO @alert_definitions
values ( N'Audit_Alert_TIN', 1, N'Information',  N'Full-Query', N'dblog.Trace_AuditTSQL_Archive', N'AuditTSQL_ID', N'select AuditTSQL_ID from dblog.Trace_AuditTSQL_Archive with (NOLOCK) where  TEXTDATA LIKE ''%TIN%''', N'Email', N'DBAMail',  N'swarndeep.singh@ebix.com', N'select @sub= ''Auditable Keywords Detected in query, Audit ID :''  + cast(AuditTSQL_ID as varchar(30)) + '' as on '' + cast(starttime as varchar(100)) from'
, N'select @body = ''<font face="verdana" size = "2"><p><font color = "red"><center><H2>Attention</H2></center></font></p><BR><BR><p>Audit for user ID<B> "'' + LoginName + ''"</B> Failed. <B></B> </p><P><B>ServerName:</B> '' + Servername + ''</p><p><B>DatabaseName:</B> '' + DBName + ''</p><p><B>Text:</B> '' + TextData + ''</p><p><b>Host Name: </b>'' + HostName + ''<p><b>SPID: </b>'' + SPID + ''</p><p><b>Reference:</b> DBLOG.Trace_AuditTSQL_Archive.AuditTSQL_ID='' + cast(AuditTSQL_ID as varchar(30))+ ''</p> <BR> Thanks <BR> Database Alert Agent<BR> <I>DO NOT REPLY to this e-mail address, contact DBA for '' + ServerName +''.</I></font>'' from', 480, 1)





-- End Audit Alert




-- This is for Job Alerts





INSERT INTO @alert_definitions
values 
(N'Agent_Failed', 1, N'Warning', N'Full-Query', N'dblog.Current_Job_Status_report' 
, N'job_num' 
, N'select job_num from dblog.current_job_status_report with (NOLOCK) where last_run_outcome = 0 and [job_enabled] = 1'
, N'Email', N'DBAMail', N'sqlhelp@ebix.com'
, N'select @sub= ''Agent Job '' + job_name + '' '' + '' failed as on '' + cast (last_run_date as varchar(100)) + '' '' + cast (last_run_time as varchar(100)) from ' , N'select  @body = ''<font face="verdana" size = "2"><p><font color = "red"><center><H2>Attention</H2></center></font></p><BR><BR><p>Agent Job <B>"'' + job_name + ''"</B> is <B>'' + cast(last_run_outcome as varchar(100)) + ''</B> </p><P><B>ServerName:</B> '' + @@servername + ''</p></B> <p><B>Reference: </B> DBLOG.Current_Job_Status_report.Job_num='' + cast(job_num as varchar(30)) + ''</p> <BR> Thanks <BR> Database Alert Agent<BR> <I>DO NOT REPLY to this e-mail address, contact DBA for '' + @@servername +''.</I></font>'' from', 480, 1)






INSERT INTO @alert_definitions
values 
(N'Full_Backup_Config', 1, N'Warning', N'Full-Query', N'sys.databases' 
, N'database_id' 
, N'select a.database_id as ''DBNAME'' from sys.databases a 
	left outer JOIN DBLOG.Backup_info b
		on a.name = b.DBName
		and b.BackupType =''D''
	where  b.DBName is null and
	a.name not in (''model'', ''tempdb'', ''distribution'', ''MDW'') '
, N'Email', N'DBAMail', N'Globalsql@ebix.com'
, N'select @sub= ''Full Backup Configuration for '' + cast(NAME as varchar(30)) + '' '' + '' Missing.''  from ' 
, N'select  @body = ''<font face="verdana" size = "2"><p><font color = "red"><center><H2>Attention</H2></center></font></p><BR><BR><p>Full Backup Configuration for Database <B>" '' + cast(NAME as varchar(30)) + ''"</B> is missing. <B> </p><P><B>ServerName:</B> '' + @@servername + ''</p></B> <p><B>Reference: </B> sys.databases='' + cast(NAME as varchar(30)) + ''</p> <BR> Thanks <BR> Database Alert Agent<BR> <I>DO NOT REPLY to this e-mail address, contact DBA for '' + @@servername +''.</I></font>'' from', 480, 1)



INSERT INTO @alert_definitions
values 
(N'Diff_Backup_Config', 1, N'Warning', N'Full-Query', N'sys.databases' 
, N'database_id' 
, N'select a.database_id as ''DBNAME'' from sys.databases a 
	left outer JOIN DBLOG.Backup_info b
		on a.name = b.DBName
		and b.BackupType =''I''
	where  b.DBName is null and
	a.name not in (''master'', ''DBLOG'', ''MSDB'',''model'', ''tempdb'', ''distribution'', ''MDW'') '
, N'Email', N'DBAMail', N'Globalsql@ebix.com'
, N'select @sub= ''Diff Backup Configuration for '' + cast(NAME as varchar(30)) + '' '' + '' Missing.''  from ' 
, N'select  @body = ''<font face="verdana" size = "2"><p><font color = "red"><center><H2>Attention</H2></center></font></p><BR><BR><p>Full Backup Configuration for Database <B>" '' + cast(NAME as varchar(30)) + ''"</B> is missing. <B> </p><P><B>ServerName:</B> '' + @@servername + ''</p></B> <p><B>Reference: </B> sys.databases='' + cast(NAME as varchar(30)) + ''</p> <BR> Thanks <BR> Database Alert Agent<BR> <I>DO NOT REPLY to this e-mail address, contact DBA for '' + @@servername +''.</I></font>'' from', 480, 1)



INSERT INTO @alert_definitions

	values 
	(N'Log_Backup_Config', 0, N'Warning', N'Full-Query', N'sys.databases' 
	, N'database_id' 
	, N'select a.database_id as ''DBNAME'' from sys.databases a 
		left outer JOIN DBLOG.Backup_info b
			on a.name = b.DBName
			and b.BackupType =''L''
		where  b.DBName is null and
		a.name not in (''master'', ''DBLOG'', ''MSDB'',''model'', ''tempdb'', ''distribution'', ''MDW'') '
	, N'Email', N'DBAMail', N'Globalsql@ebix.com'
	, N'select @sub= ''Log Backup Configuration for '' + cast(NAME as varchar(30)) + '' '' + '' Missing.''  from ' 
	, N'select  @body = ''<font face="verdana" size = "2"><p><font color = "red"><center><H2>Attention</H2></center></font></p><BR><BR><p>Full Backup Configuration for Database <B>" '' + cast(NAME as varchar(30)) + ''"</B> is missing. <B> </p><P><B>ServerName:</B> '' + @@servername + ''</p></B> <p><B>Reference: </B> sys.databases='' + cast(NAME as varchar(30)) + ''</p> <BR> Thanks <BR> Database Alert Agent<BR> <I>DO NOT REPLY to this e-mail address, contact DBA for '' + @@servername +''.</I></font>'' from', 480, 1)




INSERT INTO @alert_definitions
values 
	
	(N'Missing_Full_Backup', 1, N'Error', N'Full-Query', N'sys.databases' 
	, N'database_id' 
	, N'select DB.database_id/*, MAX(isnull(BJ.Backup_End_Time, ''2000-01-01''))*/ from sys.databases DB with (NOLOCK) 
		join DBLOG.Backup_info BI with (NOLOCK)
			on BI.DBName = DB.name
			and BI.BackupType = ''D''		
		left outer join dblog.Backup_Jobs BJ with (NOLOCK)
			on BJ.Backup_ID = BI.Backup_ID
		where DB.name not in (''TempDB'', ''DBLOG'', ''Distribution'', ''model'') and BI.Enabled = ''1''
		group by DB.database_id having MAX(isnull(BJ.Backup_End_Time, ''2000-01-01'')) < GETDATE()-10 '
	, N'Email', N'DBAMail', N'Globalsql@ebix.com'
	, N'select @sub= ''Full Backup Missing for '' + cast(NAME as varchar(30)) + '' '' + '' database.''  from ' 
	, N'select  @body = ''<font face="verdana" size = "2"><p><font color = "red"><center><H2>Attention</H2></center></font></p><BR><BR><p>Full backup not taken in last 10 days for Database <B>" '' + cast(NAME as varchar(30)) + ''" </p><P><B>ServerName:</B> '' + @@servername + ''</p></B> <p><B>Reference: </B> sys.databases='' + cast(NAME as varchar(30)) + ''</p> <BR> Thanks <BR> Database Alert Agent<BR> <I>DO NOT REPLY to this e-mail address, contact DBA for '' + @@servername +''.</I></font>'' from', 480, 1)








INSERT INTO @alert_definitions
values 
	
	(N'Missing_Diff_Backup', 1, N'Error', N'Full-Query', N'sys.databases' 
	, N'database_id' 
	, N'select DB.database_id/*, MAX(isnull(BJ.Backup_End_Time, ''2000-01-01''))*/ from sys.databases DB with (NOLOCK) 
		join DBLOG.Backup_info BI with (NOLOCK)
			on BI.DBName = DB.name
			and BI.BackupType = ''I''		
		left outer join dblog.Backup_Jobs BJ with (NOLOCK)
			on BJ.Backup_ID = BI.Backup_ID
		where DB.name not in (''master'', ''DBLOG'', ''MSDB'',''model'', ''tempdb'', ''distribution'', ''MDW'') and BI.Enabled = ''1''
		group by DB.database_id having MAX(isnull(BJ.Backup_End_Time, ''2000-01-01'')) < GETDATE()-2 '
	, N'Email', N'DBAMail', N'Globalsql@ebix.com'
	, N'select @sub= ''Differential Backup Missing for '' + cast(NAME as varchar(30)) + '' '' + '' database.''  from ' 
	, N'select  @body = ''<font face="verdana" size = "2"><p><font color = "red"><center><H2>Attention</H2></center></font></p><BR><BR><p>Differential backup not taken in last 2 days for Database <B>" '' + cast(NAME as varchar(30)) + ''" </p><P><B>ServerName:</B> '' + @@servername + ''</p></B> <p><B>Reference: </B> sys.databases='' + cast(NAME as varchar(30)) + ''</p> <BR> Thanks <BR> Database Alert Agent<BR> <I>DO NOT REPLY to this e-mail address, contact DBA for '' + @@servername +''.</I></font>'' from', 480, 1)



INSERT INTO @alert_definitions
values 
	
(N'Database_Blocking_Open_Tx', 1, N'Warning', N'Full-Query', N'master.sys.sysprocesses' 
	, N'spid' 
	, N'select distinct spid from master..sysprocesses  
where (open_tran = 1 or blocked > 0) and loginame not like ''%sql-svc%'' and last_batch <= DATEADD(MINUTE,-5,GETDATE())  
and DB_NAME(dbid) not in (''MSDB'', ''Master'', ''distribution'',''MDW'') '
	, N'Email', N'DBAMail', N'Globalsql@ebix.com'
	, N'select @sub= ''Blocking or Open Transaction '' + cast(@@servername as varchar(100)) +''.''+ cast(db_name(dbid) as varchar(30)) + ''.''  from ' 
	, N'select  @body = ''<font face="verdana" size = "2"><p><font color = "red"><center><H2>Attention</H2></center></font></p><BR><BR><p>Blocking or Open Transaction Found <B>"'' + cast(spid as varchar(10)) + ''" </p>
	<P><B>Server Name:</B> '' + @@servername + ''</p></B> 
	<P><B>Database Name:</B> '' + cast(db_name(dbid) as varchar(50)) + ''</p></B>
	<P><B>SPID:</B> '' + cast(spid as varchar(10)) + ''</p></B>
	<P><B>Batch Date:</B> '' + cast(last_batch as varchar(100)) + ''</p></B>
	<P><B>Open Transaction ?:</B> '' + case when cast(open_tran as varchar(100)) = 1 then ''Yes'' else ''NO'' end + ''</p></B>
	<P><B>Blocking SPID:</B> '' + cast(blocked as varchar(10))+ ''</p></B>
	<P><B>Host Name:</B> '' + cast(hostname as varchar(100))+ ''</p></B>
	<P><B>Application Name:</B> '' + cast(program_name as varchar(100))+ ''</p></B>
	<P><B>User:</B> '' + cast(nt_username as varchar(100))+ ''</p></B>
	<P><B>Login:</B> '' + cast(loginame as varchar(100)) + ''</p></B>
	
	<BR> Thanks <BR> Database Alert Agent<BR> <I>DO NOT REPLY to this e-mail address, contact DBA for '' + @@servername +''.</I></font>'' from', 30, 20)








-- End Audit Alert

MERGE DBLog.Alert_Definitions 
USING (SELECT [AlertName], [Enabled],[AlertType],[AlertQuery_Type],[AlertTable],
[AlertColumn],[AlertQuery],[AlertMethod],[EmailProfile],[AlertRecipients],
[AlertSubject_Query],[AlertBody_Query],[AlertGap_minutes],[MaxAlerts] FROM @alert_definitions) 
AS updatedData

([AlertName], [Enabled],[AlertType],[AlertQuery_Type],[AlertTable],
[AlertColumn],[AlertQuery],[AlertMethod],[EmailProfile],[AlertRecipients],
[AlertSubject_Query],[AlertBody_Query],[AlertGap_minutes],[MaxAlerts])
ON (DBLog.Alert_Definitions.AlertName = updatedData.AlertName)
WHEN NOT MATCHED THEN
INSERT([AlertName], [Enabled],[AlertType],[AlertQuery_Type],[AlertTable],
[AlertColumn],[AlertQuery],[AlertMethod],[EmailProfile],[AlertRecipients],
[AlertSubject_Query],[AlertBody_Query],[AlertGap_minutes],[MaxAlerts])

VALUES(updatedData.[AlertName], updatedData.[Enabled],updatedData.[AlertType],updatedData.[AlertQuery_Type],updatedData.[AlertTable],
updatedData.[AlertColumn],updatedData.[AlertQuery],updatedData.[AlertMethod],updatedData.[EmailProfile],updatedData.[AlertRecipients],updatedData.[AlertSubject_Query],updatedData.[AlertBody_Query],updatedData.[AlertGap_minutes],updatedData.[MaxAlerts])

WHEN MATCHED THEN
UPDATE
SET alerttable = updatedData.alerttable
,alertcolumn = updatedData.alertcolumn
,alertquery = updatedData.alertquery
,alertsubject_query = updatedData.alertsubject_query
,alertBody_query = updatedData.alertBody_query;
end



if not exists(select 1 from [DBLog].[Error_Alert] where alert_name = 'Backup_Failed')
	INSERT [DBLog].[Error_Alert] ([Alert_Name], [ErrorID]) VALUES (N'Backup_Failed', N'8801')
if not exists(select  1 from [DBLog].[Error_Alert] where alert_name = 'Backup_Stuck')
	INSERT [DBLog].[Error_Alert] ([Alert_Name], [ErrorID]) VALUES (N'Backup_Stuck', N'8802')
if not exists(select 1 from  [DBLog].[Error_Alert] where alert_name = 'Open_Items')
	INSERT [DBLog].[Error_Alert] ([Alert_Name], [ErrorID]) VALUES (N'Open_Items', N'8701')
if not exists(select 1 from [DBLog].[Error_Alert]  where alert_name = 'Transfer_Failed')
	INSERT [DBLog].[Error_Alert] ([Alert_Name], [ErrorID]) VALUES (N'Transfer_Failed', N'8901')
if not exists(select  1 from [DBLog].[Error_Alert] where alert_name = 'Transfer_Stuck')
	INSERT [DBLog].[Error_Alert] ([Alert_Name], [ErrorID]) VALUES (N'Transfer_Stuck', N'8902')
if not exists(select 1 from [DBLog].[Error_Alert]  where alert_name = 'Audit_Alert_Star')
	INSERT [DBLog].[Error_Alert] ([Alert_Name], [ErrorID]) VALUES (N'Audit_Alert_Star', N'8703')
if not exists(select 1 from [DBLog].[Error_Alert]  where alert_name = 'Agent_Failed')
	INSERT [DBLog].[Error_Alert] ([Alert_Name], [ErrorID]) VALUES (N'Agent_Failed', N'8702')
if not exists(select 1 from [DBLog].[Error_Alert]  where alert_name = 'Audit_Alert_TIN')
	INSERT [DBLog].[Error_Alert] ([Alert_Name], [ErrorID]) VALUES (N'Audit_Alert_TIN', N'8705')
if not exists(select 1 from [DBLog].[Error_Alert]  where alert_name = 'Audit_Alert_Social')
	INSERT [DBLog].[Error_Alert] ([Alert_Name], [ErrorID]) VALUES (N'Audit_Alert_Social', N'8704')

if not exists(select 1 from [DBLog].[Error_Alert]  where alert_name = 'Full_Backup_Config')
	INSERT [DBLog].[Error_Alert] ([Alert_Name], [ErrorID]) VALUES (N'Full_Backup_Config', N'8601')
if not exists(select 1 from [DBLog].[Error_Alert]  where alert_name = 'Diff_Backup_Config')
	INSERT [DBLog].[Error_Alert] ([Alert_Name], [ErrorID]) VALUES (N'Diff_Backup_Config', N'8602')
if not exists(select 1 from [DBLog].[Error_Alert]  where alert_name = 'Log_Backup_Config')
	INSERT [DBLog].[Error_Alert] ([Alert_Name], [ErrorID]) VALUES (N'Log_Backup_Config', N'8603')


if not exists(select 1 from [DBLog].[Error_Alert]  where alert_name = 'Missing_Full_Backup')
	INSERT [DBLog].[Error_Alert] ([Alert_Name], [ErrorID]) VALUES (N'Missing_Full_Backup', N'8604')

if not exists(select 1 from [DBLog].[Error_Alert]  where alert_name = 'Missing_Diff_Backup')
	INSERT [DBLog].[Error_Alert] ([Alert_Name], [ErrorID]) VALUES (N'Missing_Diff_Backup', N'8605')


if not exists(select 1 from [DBLog].[Error_Alert]  where alert_name = 'Database_Blocking_Open_Tx')
	INSERT [DBLog].[Error_Alert] ([Alert_Name], [ErrorID]) VALUES (N'Database_Blocking_Open_Tx', N'8606')





-- Misc Propeties
if not exists (select 1 from [DBLog].[MiscProperties] where propertyname ='Location_Password_1')
	INSERT [DBLog].[MiscProperties] ([PropertyName], [Propertyvalue]) VALUES (N'Location_Password_1', N'34lj3ls,,.!~===+{po*7)')

if not exists (select 1 from [DBLog].[MiscProperties] where propertyname ='Location_Password_2')
INSERT [DBLog].[MiscProperties] ([PropertyName], [Propertyvalue]) VALUES (N'Location_Password_2', N'FGHJ%^&YGUF^*%%')

if not exists (select 1 from [DBLog].[MiscProperties] where propertyname ='FTP_FIle_Name')
INSERT [DBLog].[MiscProperties] ([PropertyName], [Propertyvalue]) VALUES (N'FTP_FIle_Name', N'U9_')
GO

if not exists (select 1 from [DBLog].[MiscProperties] where propertyname ='Backup_Full_Auto_Manual')
INSERT [DBLog].[MiscProperties] ([PropertyName], [Propertyvalue]) VALUES (N'Backup_Full_Auto_Manual', N'Auto')
GO

if not exists (select 1 from [DBLog].[MiscProperties] where propertyname ='Backup_Diff_Auto_Manual')
INSERT [DBLog].[MiscProperties] ([PropertyName], [Propertyvalue]) VALUES (N'Backup_Diff_Auto_Manual', N'Auto')
GO

if not exists (select 1 from [DBLog].[MiscProperties] where propertyname ='Backup_Log_Auto_Manual')
INSERT [DBLog].[MiscProperties] ([PropertyName], [Propertyvalue]) VALUES (N'Backup_Log_Auto_Manual', N'Manual')
GO


if not exists (select 1 from [DBLog].[MiscProperties] where propertyname ='BlockingProcessThreshold')
INSERT [DBLog].[MiscProperties] ([PropertyName], [Propertyvalue]) VALUES (N'BlockingProcessThreshold', N'6')
GO



-- DBLog.FTP_info

if not exists(select 1 from DBLog.FTP_info with (NOLOCK) where ftp_name ='FTP_SmartMonitor_RowCount')
begin
	INSERT [DBLog].[FTP_Info] ([FTP_Name], [FTP_Server], [FTP_User_Name], [FTP_Path], [work_folder]) VALUES (N'FTP_SmartMonitor_RowCount', N'smftp.ez-data.com', N'anetsm', N'/SmartMonitor/Maintenance_Logs/RecordCount/A3', N'G:\testFolder\Logs')
end

if not exists(select 1 from DBLog.FTP_info with (NOLOCK) where ftp_name ='FTP_SmartMonitor_ML')
begin
	INSERT [DBLog].[FTP_Info] ([FTP_Name], [FTP_Server], [FTP_User_Name], [FTP_Path], [work_folder]) VALUES (N'FTP_SmartMonitor_ML', N'smftp.ez-data.com', N'anetsm', N'/SmartMonitor/Maintenance_Logs/RecordCount/A3', N'G:\testFolder\Logs')
end



-- Add roles
if not exists(select 1 from [DBLog].[Roles] where RoleName = 'Administrator')
	INSERT [DBLog].[Roles] ([RoleName], [RoleDescription]) VALUES (N'Administrator', N'Can do everything as user can do, additionaly can create more users')
if not exists(select 1 from [DBLog].[Roles] where RoleName = 'BCP_user')	
	INSERT [DBLog].[Roles] ([RoleName], [RoleDescription]) VALUES (N'BCP_user', N'For BCP')
if not exists(select 1 from [DBLog].[Roles] where RoleName = 'ftp_user')	
	INSERT [DBLog].[Roles] ([RoleName], [RoleDescription]) VALUES (N'ftp_user', N'Just for FTP')
if not exists(select 1 from [DBLog].[Roles] where RoleName = 'User')		
	INSERT [DBLog].[Roles] ([RoleName], [RoleDescription]) VALUES (N'User', N'Can do all functions, but not user administration')



-- LOcation Detail for BCP User
if not exists (select 1 from dblog.Location_Details where LocationID = 101)
begin
	insert into dblog.Location_Details
	select 101, '[BCP_Location]',0,'y:','User','PWD'
end

-- dblog.users


if not exists (select 1 from dblog.Users where UserName = 'anetsm')
begin
	exec DBLog.usp_Add_User 'anetsm','1234', 'ftp_user','andbg@ebix.com'
end


if not exists (select 1 from dblog.Users where UserName = 'dp_user')
begin
	exec DBLog.usp_Add_User 'dp_user','1234', 'BCP_user','andbg@ebix.com'
end



/****** Object:  Table [DBLog].[backup_exceptions] ******/
if not exists (select 1 from dblog.backup_exceptions)
begin
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'Distribution', N'D')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'Distribution', N'I')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'Distribution', N'L')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'Master', N'I')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'Master', N'L')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'Model', N'D')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'Model', N'I')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'Model', N'L')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'MSDB', N'I')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'MSDB', N'L')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'Temp', N'D')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'Temp', N'I')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'Temp', N'L')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'TempDB', N'D')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'TempDB', N'I')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'TempDB', N'L')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'Test', N'D')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'Test', N'I')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'Test', N'L')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'DBLog', N'I')
	INSERT [DBLog].[backup_exceptions] ([DBName], [backuptype]) VALUES (N'DBLog', N'L')
end






/***** Add Backup Tools information here *****/
if not exists (select 1 from dblog.Backup_Tools where backupToolID = 'SQL')
	insert DBLOG.Backup_Tools (backupToolID, backupToolName) VALUES ('SQL','Native')

if not exists (select 1 from dblog.Backup_Tools where backupToolID = 'RGT')
	insert DBLOG.Backup_Tools (backupToolID, backupToolName) VALUES ('RGT','RedGate')

if not exists (select 1 from dblog.Backup_Tools where backupToolID = 'LSD')
	insert DBLOG.Backup_Tools (backupToolID, backupToolName) VALUES ('LSD','Litespeed')
