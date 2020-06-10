CREATE procedure [DBLog].[usp_DBUsage_RecordCount_prepare_SM] @locationID int, @FTPName varchar(50)
as
Print 'Disabled Procedure - Now taken care by RTM'
/*
set nocount on
declare @databasename varchar(200), @location varchar(4000), @sqlquery varchar(4000), @vwQUERY nvarchar(4000)
, @bcpquery varchar(6000), @filename varchar(100), @identity int, @ftp_id int

set @identity = 0


select @ftp_id = ftp_id from dblog.ftp_info 
where FTP_Name = @FTPName

declare @pass1 varchar(500)
declare @DecryptedPassword varchar(50), @encryptedPassword varchar(5000)
select @pass1= PropertyValue from DBLog.MiscProperties where PropertyName = 'Location_Password_1'


select @encryptedPassword = a.password from dblog.users a 
	join dblog.users_roles b
		on a.username = b.username
	where a.username ='dp_user';
	
set @DecryptedPassword = decryptbypassphrase(@pass1,@encryptedpassword)	
	
/*declare dbLogCur cursor
for
select distinct DatabaseName from dblog.DBUsage with (NOLOCK) where DatabaseName not in
('master','distribution','tempdb','model','dblog','db_log') and CollectionDate > GETDATE()-1

open dbLogCur

Fetch next from dblogcur
INTO @databasename

WHILE @@FETCH_STATUS = 0
BEGIN
*/
exec DBLog.usp_MapLocation @locationID, @location output

select  @filename = propertyvalue + '-RecCount-' + CONVERT(varchar(10),getdate(),112) 
+'.log'
from dblog.MiscProperties where PropertyName = 'FTP_FIle_Name';



set @sqlquery = '
select QUOTENAME(''REPORTDATE'',''"'') [REPORT_DATE], QUOTENAME( ''TABLE_NAME'',''"'') [TABLE_NAME], QUOTENAME(''NUM_ROWS'',''"'') [NUM_ROWS], QUOTENAME(''TABLE_SIZE'',''"'') [TABLE_SIZE]
UNION ALL
select QUOTENAME(UPPER(REPLACE(CONVERT(VARCHAR(9), CollectionDate, 6), '' '', ''-'')),''"'') [REPORT_DATE], QUOTENAME(DatabaseName + ''.'' + table_name,''"'') [table_name], quotename(row_count,''"'') [NUM_ROWS],  quotename(reserved_size,''"'') [TABLE_SIZE] from dblog.dblog.dbusage with (NOLOCK)	where DatabaseName  NOT IN (''master'',''distribution'',''tempdb'',''model'',''dblog'',''db_log'') and CollectionDate > GETDATE()-1 and table_name like ''%DBSIZE%''
UNION ALL
select QUOTENAME(UPPER(REPLACE(CONVERT(VARCHAR(9), CollectionDate, 6), '' '', ''-'')),''"'') [REPORT_DATE], QUOTENAME(DatabaseName + ''.'' + table_name,''"'') [table_name], quotename(row_count,''"'') [NUM_ROWS],  quotename(reserved_size,''"'') [TABLE_SIZE] from dblog.dblog.dbusage with (NOLOCK)	where DatabaseName  NOT IN (''master'',''distribution'',''tempdb'',''model'',''dblog'',''db_log'') and CollectionDate > GETDATE()-1 and table_name NOT like ''%DBSIZE%''';

set @vwQUERY = 'create view dblog.getdbLogCur as 
' + @sqlquery

print @sqlquery
exec sp_executesql  @vwQUERY

select @bcpquery = 'bcp "select * from dblog.dblog.getdbLogCur" queryout "' + @location + '\' + @filename + '" -c -S'+ @@SERVERNAME + ' -Udp_user -P' + @DecryptedPassword + '  -t","'; --/r\"\r\n\"


exec xp_cmdshell @bcpquery
if @@ERROR = 0
begin
	insert into DBLog.BCP_info (BCP_Location_ID,BCP_Folder,BCP_File,Message)
	select @locationID, @location, @filename, 'Completed'
	
	set @identity = @@IDENTITY
	
	insert into DBLog.FTP_Jobs (FTP_ID, BCP_ID, ftp_status)
	select @FTP_ID, @identity, 'Pending'
	
end

if @@ERROR <> 0
begin
	insert into DBLog.BCP_info (BCP_Location_ID,BCP_Folder,BCP_File,Message)
	select @locationID, @location, @filename, 'Failed'
end

exec dblog.usp_DeleteMapLocation @locationID

drop view dblog.getdbLogCur;

--fetch next from dblogcur
--into @databasename

--END
--close dblogcur
--deallocate dblogcur
*/