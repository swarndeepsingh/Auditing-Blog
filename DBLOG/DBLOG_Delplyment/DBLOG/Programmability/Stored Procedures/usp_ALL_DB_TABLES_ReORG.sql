create proc [DBLog].[usp_All_DB_Tables_ReOrg]

AS

DECLARE @dbname NVARCHAR(500) 
,@tablename NVARCHAR(500)
,@schemaname NVARCHAR(500)
,@indexname NVARCHAR(MAX)
,@pagelocks int
,@percentfragvalue DECIMAL (10,2)
,@id int 
,@max int 
,@cmdfragmentvalue NVARCHAR(MAX)
,@cmddefragmentvalue NVARCHAR(MAX) 
,@id_db int
,@WordPhrase varchar(50)
,@IndexStart varchar(50)
,@IndexEnd varchar(50)

IF OBJECT_ID('tempdb..#temp') IS NOT NULL
	DROP TABLE #temp
CREATE TABLE #temp
(
id int identity (1,1),
id_DB int 
,dbname varchar(500) not null
)
IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
	DROP TABLE #temp1
CREATE TABLE #temp1
(
id int identity (1,1)
,dbname VARCHAR(500)
,tablename VARCHAR(500)
,schemaname VARCHAR(500)
,indexname VARCHAR(500)
,pagelocks int
,avgfragmentation DECIMAL (10,2)
)
INSERT INTO #temp (id_DB,dbname)
SELECT database_id,name
FROM sys.databases
WHERE 
name not in ('tempdb','master','model','msdb','distribution', 'backup')
AND state = 0 

-- Get all indexes into #temp1
SELECT @id = 1, @max = max(id) from #temp
WHILE (@id <= @max)
BEGIN 
	SELECT @dbname =dbname FROM #temp  WHERE id = @id 
	SELECT @id_db =id_DB FROM #temp  WHERE id = @id 
	SET @cmdfragmentvalue ='INSERT INTO #temp1 (dbname, tablename, schemaname, indexname,pagelocks ,avgfragmentation) 
	 SELECT '''+@dbname+''' AS DBName ,
	 rtrim(ltrim(tb.Name)) AS TableName ,
	 rtrim(ltrim(scmas.Name)) AS SchemaName ,
	 rtrim(ltrim(ix.name)) AS IndexName ,
	 ix.allow_page_locks AS pagelocks,
	 CONVERT(decimal(10,2),ix_physical_stats.avg_fragmentation_in_percent) 
	FROM [' +@dbname+ '].sys.dm_db_index_physical_stats(DB_ID('''+@dbname+'''), NULL, NULL,  NULL, ''DETAILED'') AS ix_physical_stats 
	JOIN [' +@dbname+ '].sys.indexes ix  ON ix_physical_stats.object_Id = ix.object_id AND ix_physical_stats.index_id = ix.index_id 
	JOIN [' +@dbname+ '].sys.tables tb ON ix.object_id = tb.object_Id 
	JOIN [' +@dbname+ '].sys.schemas scmas ON tb.schema_id = scmas.SCHEMA_ID 
	WHERE ix_physical_stats.avg_fragmentation_in_percent > 5 and ix_physical_stats.page_count > 99
	AND tb.type = ''U''
	AND ix.name IS NOT NULL and DB_ID('''+@dbname+''')='+Convert(varchar,@id_db)
	EXEC(@cmdfragmentvalue) 
	set @id = @id + 1 
END

-- Execute the Index Rebuild/Reorg based on fragmentation level
SELECT @id = 1, @max = MAX(id) FROM #temp1
WHILE (@id <= @max)
-- start of while loop
BEGIN
 -- Get record set to work with
	SELECT @dbname = '['+dbname+']'
	, @tablename = '['+tablename+']'
	, @schemaname = '['+schemaname+']'
	, @indexName = indexname
	, @percentfragvalue = avgfragmentation
	,  @pagelocks = pagelocks
	FROM #temp1 
	WHERE id = @id
-- Determine if percentage is high to alter
	IF @percentfragvalue  > 20
	 BEGIN
	   -- Logic if Allow Page Lock lock is true
		IF @pagelocks = 1
			BEGIN
			  SET @WordPhrase = 'DOING ONLINE ReOrganize, the fragment % is '
			  SET @IndexStart = left(SYSDATETIME(),19)
		      SET @cmddefragmentvalue = 'ALTER INDEX '+'['+@indexName+'] ON '+@dbname+'.'+@schemaname+'.'+@tablename+ ' REORGANIZE'
		      PRINT @WordPhrase + cast(@percentfragvalue as varchar(10)) + ' ' + @cmddefragmentvalue+ '. Starting - ' + @IndexStart
			END
		ELSE
		  -- If Allow Page Lock is false
			BEGIN
			 SET @WordPhrase = 'DOING Offline ReBuild, the fragment % is '
			 SET @IndexStart = left(SYSDATETIME(),19)
			 SET @cmddefragmentvalue = 'ALTER INDEX ' + '['+@indexName +'] ON '+@dbname+'.'+@schemaname+'.'+@tablename+ ' REBUILD' +' WITH (ALLOW_PAGE_LOCKS = OFF,ALLOW_ROW_LOCKS  = ON, ONLINE = OFF,FILLFACTOR = 80)'
			 PRINT @WordPhrase + cast(@percentfragvalue as varchar(10)) + ' ' + @cmddefragmentvalue + '. Starting - ' + @IndexStart
			END
		-- run the above statement
		Exec sp_executesql @cmddefragmentvalue
	 END

	--IF @percentfragvalue  > 30
	--BEGIN
	--	SET @cmddefragmentvalue = 'ALTER INDEX ' + '['+@indexName +'] ON '+@dbname+'.'+@schemaname+'.'+@tablename+ ' REBUILD' +' WITH (FILLFACTOR = 80)'
	--	PRINT 'DOING ReIndex, the fragment level is ' + cast(@percentfragvalue as varchar(10)) + ' ' + @cmddefragmentvalue + '. Starting - ' + cast(getdate() as varchar(50))
	--	Exec sp_executesql @cmddefragmentvalue
	--END
	SET @id = @id + 1 
	
END


-- NO UPDATE STATISTICS in this job
/*
-- Perform the Update Statistics task
SELECT @id = 1, @max = max(id) from #temp
WHILE (@id <= @max)
BEGIN

	set @cmddefragmentvalue = @dbname + '.sys.sp_updatestats'
	exec @cmddefragmentvalue
END
*/