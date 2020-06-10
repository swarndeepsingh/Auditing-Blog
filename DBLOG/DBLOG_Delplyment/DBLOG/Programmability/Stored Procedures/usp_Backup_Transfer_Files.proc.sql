create PROC [DBLog].[usp_Backup_Transfer_Files]
as
declare @transferid int, @source varchar(8000), @destination varchar(8000), @sqltext varchar(8000), @sourcelocationid int, @destinationlocationid int
declare @message varchar(8000), @source_path varchar(8000), @source_file varchar(8000)
declare @exitcode int
select top 1 @transferid = transfer_id, @source=[Source], @destination = Destination
, @sourcelocationid = sourcelocationid, @destinationlocationid = destinationlocationid
from DBLog.Backup_transfer_Job with (NOLOCK)
where Status = 'Pending' and startdate is NULL
order by Backup_Job_ID asc


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
set @sqltext = 'robocopy "' + @source_path + '" "' + @destination + '" ' + @source_file + ' /log:"' + @source_path +'\'+ @source_file+ '_transfer_log.log" ' +' /R:5 /W:180 /Z /tee /np /Copy:DT'

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