CREATE procedure [DBLog].[usp_DBUsage_MaintenanceLog_prepare_SM] @locationID int, @FTPName varchar(50)
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
select distinct DBName from dblog.Backup_info with (NOLOCK) where DBName not in
('master','distribution','tempdb','model') 

open dbLogCur

Fetch next from dblogcur
INTO @databasename

WHILE @@FETCH_STATUS = 0
BEGIN*/
exec DBLog.usp_MapLocation @locationID, @location output

select  @filename = propertyvalue + '-ML-' + CONVERT(varchar(10),getdate(),112) 
+'.log'
from dblog.MiscProperties where PropertyName = 'FTP_FIle_Name'




select @bcpquery = 'bcp "SELECT JOB_DATE [JOB_DATE] , [JOB_TYPE], START_TIME	,END_TIME , [TIME_TAKEN], [IS_SUCCESS], [JOBSIZE] from dblog.dblog.vw_SM_MaintenanceLog_24hr  order by job_date desc" queryout "' + @location + '\' + @filename + '" -c -S'+ @@SERVERNAME + ' -Udp_user -P' + @DecryptedPassword + '  -t","'; --/r\"\r\n\"


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



--fetch next from dblogcur
--into @databasename

--END
--close dblogcur
--deallocate dblogcur

*/