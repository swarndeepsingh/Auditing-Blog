CREATE Proc [DBLog].[usp_Del_OSFile] @tracename varchar(255)=''
as
declare @filename varchar(4000)
declare @sqltext varchar(5000)
declare delFile CURSOR FOR
	select tracefile from [DBLOG].Trace_Info with (NOLOCK) 
	where active = 0 and archived = 1 and filedeleted =0 
	order by createdate asc
OPEN delFILE 
FETCH NEXT FROM delFile into @filename
WHILE @@FETCH_STATUS = 0
BEGIN
	set @sqltext = 'master.dbo.xp_cmdshell ''DEL "' + @filename + '.*"'''
	EXEC(@sqltext)
	print @sqltext
	update [DBLOG].Trace_Info
	SET FileDeleted = 1
	where TraceFile = @filename
	 
	FETCH NEXT FROM delFile into @filename
END
CLOSE delFile
Deallocate delFile