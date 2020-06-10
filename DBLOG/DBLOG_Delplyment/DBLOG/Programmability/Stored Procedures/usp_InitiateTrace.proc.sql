CREATE Proc [DBLog].[usp_InitiateTrace] @Tname varchar(255)
as
declare @TraceName varchar(255), @SPName varchar(255), @active int, @error varchar(500)
DECLARE @folderpath varchar(255), @interval int, @Lastimported datetime, @status varchar(255)
DECLARE @query varchar(1000)
DECLARE @rundate varchar(50)

select 
	@TraceName=tracename
,	@SPName=spname
,	@active = active
from [DBLOG].trace_jobs with (NOLOCK)
where tracename=@Tname

if @active =0
begin
	set @error = 'Trace is disabled, quiting'
	GOTO QUIT1
end

if @active = 1
begin
	select @folderpath = propertyvalue 	from Trace_Properties with (NOLOCK) where propertyname ='FolderPath' and tracename= @tracename
	select @interval = cast(propertyvalue as int) 	from Trace_Properties with (NOLOCK) where propertyname ='Interval' and tracename= @tracename
	select @lastimported = cast(propertyvalue as datetime) 	from Trace_Properties with (NOLOCK) where propertyname ='LastImported' and tracename= @tracename
	select @status = propertyvalue 	from Trace_Properties with (NOLOCK) where propertyname ='status' and tracename= @tracename
	

	if DATEDIFF(mi,@Lastimported,GETDATE()) > = @interval
	begin

		set @query= 'EXEC ' + @SPName + ' ''' + @status + ''', ''' + @folderpath + ''', ''' + @tracename + ''''
		exec(@query)
	end

	if DATEDIFF(mi,@Lastimported,GETDATE()) < @interval
	begin
		set @rundate = convert(varchar(50),dateadd(mi, @interval, @Lastimported),121)
		raiserror ('Trace Properties are set to run after %s, please try later.', 10,1,@rundate)
	end
end


return
QUIT1:
raiserror (@error, 15,1)
print 'Exited'