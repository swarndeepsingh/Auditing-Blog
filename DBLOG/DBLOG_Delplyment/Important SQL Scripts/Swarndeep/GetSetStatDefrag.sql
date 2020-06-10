use master;
if exists (select 1 from sys.objects where name = 'usp_GetSetStatsFragmentation')
	drop procedure usp_GetSetStatsFragmentation
GO
create proc usp_GetSetStatsFragmentation(@databasename varchar(100), @schemaname varchar(100), @tablenames varchar(8000), @options varchar(1024))
as
SET NOCOUNT ON;  
declare @tabname varchar(100), @objid bigint, @schname varchar(100), @statname varchar(1024)

declare @statsinfo table
(
		schemaName varchar(100),
        tableName varchar(100),
        statsName varchar(100),
        objectid bigint,
        statsid bigint,
        LastUpdated datetime,
        statsType varchar(100),
        indexName varchar(1024),
        modCounter bigint,
        row_count bigint,
		rows_sampled bigint
       ,mod_percent numeric(10,2)
)
declare @command varchar(5000)
, @db_id smallint

declare @tables as table
	(
	Objectid bigint,
	Tablename varchar(100),
	Schemaname varchar(100)
	)

declare @option as table
(
Optionname varchar(50)
)

select @db_id = DB_ID(@databasename)



insert into @tables
exec('
select obj.object_id, obj.name, sch.name  from '+ @databasename +'.sys.objects obj
join '+ @databasename +'.sys.schemas sch
	on obj.schema_id = sch.schema_id
	and sch.name = '''+@schemaname+'''
join master..[fnSplitString] ('''+@tablenames+''','','') inputtables
	on inputtables.splitdata =obj.name
	')



	
insert into @option
select * from [fnSplitString] (@options,',')

declare stat cursor for
select objectid, tablename, schemaname from @tables

open stat
fetch next from stat into @objid, @tabname, @schname

while @@FETCH_STATUS = 0
begin

	insert into @statsinfo
	exec ('USE ' +@databasename+ '; SELECT  statsSummary.schemaName,
        statsSummary.tableName,
        statsSummary.statsName,
        statsSummary.objectid,
        statsSummary.statsid,
        statsSummary.LastUpdated,
        statsSummary.statsType,
        statsSummary.indexName,
        --statsSummary.index_id,
        statsSummary.modCounter,
        rowCounts.row_count ,
		statssummary.rows_sampled,
       (statsSummary.modCounter*1.00)/(rowCounts.row_count*1.00)  *100 [percent]
FROM (
        SELECT  sc.name schemaName,
                o.name tableName,
                s.name statsName,
                s.object_id [objectid],
                s.stats_id [statsid],
                STATS_DATE(o.object_id, s.stats_id) LastUpdated,
                CASE WHEN i.name IS NULL THEN ''COLUMN'' ELSE ''INDEX'' END AS StatsType,
                ISNULL( i.name, ui.name ) AS indexName,
                ISNULL( i.index_id, ui.index_id ) AS index_id, 
                sp.modification_counter AS modCounter,
				sp.rows_sampled
				
        FROM '+ @databasename +'.sys.stats s
		
            INNER JOIN '+ @databasename +'.sys.objects o ON s.object_id = o.object_id
            INNER JOIN '+ @databasename +'.sys.schemas sc ON o.schema_id = sc.schema_id
            LEFT JOIN '+ @databasename +'.sys.indexes i ON s.object_id = i.object_id AND s.stats_id = i.index_id
			
            -- If the statistics object is not on an index, get the underlying table
            LEFT JOIN '+ @databasename +'.sys.indexes ui ON s.object_id = ui.object_id AND ui.index_id IN ( 0, 1 )
			
            CROSS APPLY '+ @databasename +'.sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp
			
            where o.is_ms_shipped = 0
			
			
			and o.object_id =' + @objid +'
			
			
			and sc.name = ''' + @schname + '''
    ) AS statsSummary
	
    INNER JOIN (
        SELECT object_id, index_id, SUM(row_count) row_count
        FROM '+ @databasename +'.sys.dm_db_partition_stats
        GROUP BY object_id, index_id
        HAVING SUM( row_count ) > 0
    ) AS rowCounts ON statsSummary.objectid = rowCounts.object_id 
        AND statsSummary.index_id = rowCounts.index_id
        order by ((statsSummary.modCounter*1.00)/(rowCounts.row_count*1.00)) desc')
		
	fetch next from stat into @objid, @tabname, @schname
end
close stat
deallocate stat


if exists(select 1 from @option where optionname in( 'display'))	
	select * from @statsinfo order by mod_percent desc

if exists(select 1 from @option where optionname in( 'execute'))	
begin
	declare execstat cursor for
	select distinct tablename, schemaname, statsname from @statsinfo where mod_percent > 0
	
	open execstat
	fetch next from execstat into @tabname, @schname, @statname

	while (@@FETCH_STATUS = 0)
	begin
		
		PRINT 'Starting - UPDATE STATISTICS '+ @schname + '.' + @tabname + '(' + @statname + ')  WITH FULLSCAN: ' --+ cast(getdate() as varchar(50))
		exec ('use '+ @databasename +'; UPDATE STATISTICS '+ @schname + '.' + @tabname + '(' + @statname + ')  WITH FULLSCAN')
		PRINT 'Completed - UPDATE STATISTICS '+ @schname + '.' + @tabname + '(' + @statname + ')  WITH FULLSCAN: '-- + cast(getdate() as varchar(50))
		fetch next from execstat into @tabname, @schname, @statname
	end
	close execstat
	deallocate execstat
end
GO



exec usp_GetSetStatsFragmentation 'DBLOG', 'DBLOG', 'alert_events,Trace_Auditsql_archive', 'display,execute'

