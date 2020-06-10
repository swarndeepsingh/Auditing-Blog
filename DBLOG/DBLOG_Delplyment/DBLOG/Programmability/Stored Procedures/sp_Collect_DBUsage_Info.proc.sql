
Create procedure [DBLog].[sp_Collect_DBUsage_Info]
as
SET NOCOUNT ON   
declare @dbname varchar(1024)
declare @query varchar(4000)


insert DBLog.dblog.DBUsage      
SELECT cast(getdate() as date) [CollectionDate], @@SERVERNAME as [ServerName],
d.name [DatabaseName], 'DBSIZE' [Table_Name],
ROUND(SUM(cast(mf.size as bigint)) * 8 / 1024, 0) [row_count]
, ROUND(SUM(cast(mf.size as bigint)) * 8 / 1024, 0) [reserved_size] -- IN MB
, ROUND(SUM(cast(mf.size as bigint)) * 8 / 1024, 0) [space_used]
FROM sys.master_files mf
INNER JOIN sys.databases d ON d.database_id = mf.database_id
Where d.name not in ('tempdb','master','model')
GROUP BY d.name
ORDER BY d.name

  

declare Table_Fetch cursor  fast_forward FOR
select name from sys.databases where name not in ('tempdb','master','model') 

open Table_Fetch

fetch next from Table_Fetch into @dbname

While @@FETCH_STATUS = 0
begin
	set @query = 'insert DBLog.dblog.DBUsage 
	select cast(getdate() as date) collectionDate, @@SERVERNAME Servername, ''['+   
	@dbname + ']'' [DatabaseName], ss.name  + ''.'' + so.name tableName, max(p.row_count) as ''RowCount'' 
	,(SUM(p.reserved_page_count)*8*1024) reservedSize    
	,(sum(p.used_page_count)*8*1024) space_Used    
	 from [' + @dbname + '].sys.dm_db_partition_stats p  with (NOLOCK)  
	 inner join [' + @dbname + '].sys.objects so     with (NOLOCK)
	 on p.object_id = so.object_id    
	inner join [' + @dbname + '].sys.schemas ss    
	 on so.schema_id = ss.schema_id    
	where so.is_ms_shipped = 0    
	and DB_NAME() not in (''tempdb'',''msdb'',''master'',''model'')  
	group by ss.name,so.name,  p.object_id, so.object_id  '
	
	-- print @query
	execute(@query)
	
	fetch next from Table_Fetch into @dbname
end
close Table_Fetch
deallocate table_fetch

SET NOCOUNT OFF
GO