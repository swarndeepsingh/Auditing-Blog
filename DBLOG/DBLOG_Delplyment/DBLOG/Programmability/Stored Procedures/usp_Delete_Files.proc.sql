CREATE PROC [DBLog].[usp_Delete_Files]
as
declare @deleteid int, @source varchar(8000), @sqltext varchar(max), @locationid int
declare @message varchar(8000)

create table #error
(
error varchar(8000)
)


declare Delete_Files cursor
for
select  delete_id, File_Location, LocationID
from DBLog.Backup_Delete_Files with (NOLOCK)
where Status = 'Pending' and start_time is NULL
order by delete_id asc

OPEN Delete_Files
Fetch Next from Delete_Files into @deleteid, @source, @locationid
while @@FETCH_STATUS = 0
	BEGIN
		Exec DBLog.usp_MapLocation @locationID, ''
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

		update dblog.Backup_Delete_Files 
		set Start_Time = GETDATE(), status='Deleting'
		where Delete_ID = @deleteid


		set @sqltext = 'master.dbo.xp_cmdshell ''del "' + @source + '*"'''
		insert into #error
		EXEC(@sqltext)

		select top 1 @message = error from #error where error is not NULL
		select * from #error
		
		update dblog.Backup_Delete_Files 
		set [message] = @message, end_time = GETDATE(), Status = 'Completed'
		where Delete_ID = @deleteid

		-- EXEC sp_configure 'xp_cmdshell', 0
		-- reconfigure with override

		-- EXEC sp_configure 'Show Advanced Options', 0
		-- reconfigure with override
		
		drop table #ShowAdvancedOptions
		drop table #xp_cmdshell
		truncate table #error
		
		EXEC DBLog.usp_DeleteMapLocation @locationID
		Fetch Next from Delete_Files into @deleteid, @source, @locationid
	END
	drop table #error
close Delete_Files
deallocate Delete_Files