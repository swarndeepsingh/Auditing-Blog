create procedure [DBLog].[sp_dbUsage]
as
SET NOCOUNT ON
DBCC UPDATEUSAGE(0) with no_infomsgs
/*

declare @dbsize bigint, @logsize bigint, @reservedpages bigint, @usedpages bigint, @pages bigint

select @dbsize = sum(convert(bigint,case when status & 64 = 0 then size else 0 end))  
  , @logsize = sum(convert(bigint,case when status & 64 <> 0 then size else 0 end))  
  from dbo.sysfiles  
  
 select @reservedpages = sum(a.total_pages),  
  @usedpages = sum(a.used_pages),  
  @pages = sum(  
    CASE  
     -- XML-Index and FT-Index internal tables are not considered "data", but is part of "index_size"  
     When it.internal_type IN (202,204,211,212,213,214,215,216) Then 0  
     When a.type <> 1 Then a.used_pages  
     When p.index_id < 2 Then a.data_pages  
     Else 0  
    END  
   )  
 from sys.partitions p join sys.allocation_units a on p.partition_id = a.container_id  
  left join sys.internal_tables it on p.object_id = it.object_id  
  
 /* unallocated space could not be negative */  
 select   cast(getdate() as date) collectionDate, @@SERVERNAME Servername,
  [DatabaseName] = db_name(), 'DatabaseSize' as  tableName,0 as 'RowCount',
  Reserved_Size = ((convert (dec (15,2),@dbsize) + convert (dec (15,2),@logsize))
   * 8)/1024 ,  
  'Space_Used' = case when @dbsize >= @reservedpages then  
   (((convert (dec (15,2),@dbsize) + convert (dec (15,2),@logsize))
   * 8)/1024)-(((convert (dec (15,2),@dbsize) - convert (dec (15,2),@reservedpages))   
   * 8)/1024)  else 0 end
   
   UNION ALL
select cast(getdate() as date) collectionDate, @@SERVERNAME Servername,
DB_NAME() [DatabaseName], ss.name  + '.' + so.name tableName, sum(p.row_count) as 'RowCount'
,(SUM(p.reserved_page_count)*8)/1024 reservedSize
,(sum(p.used_page_count)*8)/1024 space_Used
 from sys.dm_db_partition_stats p
 inner join sys.objects so 
	on p.object_id = so.object_id
inner join sys.schemas ss
	on so.schema_id = ss.schema_id
where so.is_ms_shipped = 0
group by ss.name,so.name,  p.object_id, so.object_id
--order by ss.name,so.name desc
*/
GO


