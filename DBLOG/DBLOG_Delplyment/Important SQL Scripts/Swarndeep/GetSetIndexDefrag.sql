use master;

if  exists(select 1 from sys.objects where name = 'fnSplitString')
	drop function [fnSplitString];


use master
GO

CREATE FUNCTION [dbo].[fnSplitString] 
( 
    @string NVARCHAR(MAX), 
    @delimiter CHAR(1) 
) 
RETURNS @output TABLE(splitdata NVARCHAR(MAX) 
) 
BEGIN 
    DECLARE @start INT, @end INT 
    SELECT @start = 1, @end = CHARINDEX(@delimiter, @string) 
    WHILE @start < LEN(@string) + 1 BEGIN 
        IF @end = 0  
            SET @end = LEN(@string) + 1
       
        INSERT INTO @output (splitdata)  
        VALUES(SUBSTRING(@string, @start, @end - @start)) 
        SET @start = @end + 1 
        SET @end = CHARINDEX(@delimiter, @string, @start)
        
    END 
    RETURN 
END

GO

if exists(select 1 from sys.objects where name = 'usp_GetSetIndexFragmentation')
drop procedure usp_GetSetIndexFragmentation
GO


create proc usp_GetSetIndexFragmentation(@databasename varchar(100), @schemaname varchar(100), @tablenames varchar(8000), @options varchar(1024))
as
SET NOCOUNT ON;  



 DECLARE @objid bigint
 declare @tabname varchar(100)
 declare @indexname varchar(100)
DECLARE @sqlQuery nvarchar(4000)
declare @db_id smallint
declare @command varchar(5000)

declare @tables as table
	(
	Tablename varchar(100)
	)

declare @option as table
(
Optionname varchar(50)
)

declare @tableindexes as table
(
	tableid bigint,
	IndexID bigint,
	IndexName varchar(max)
)


declare @alltables as table
(
objectid bigint
, schemaid bigint
, tablename varchar(1024)
, schemaname varchar(512)
)


declare @indexstatistics
as table
(
	tablename varchar(100),
	indexname varchar(100),
	allotype varchar(100),
	fragmentationlevel numeric(20,2),
	schemaname varchar(100) not null
)

select @db_id = DB_ID(@databasename)

insert into @alltables
exec('SELECT tb.object_id, tb.schema_id,tb.name tablename, sch.name schemaname FROM ' + @databasename+ '.' + 'SYS.OBJECTS tb
JOIN ' + @databasename+ '.' + 'SYS.SCHEMAS sch
	on tb.schema_id = sch.schema_id
where tb.type in (''U'', ''V'')')



insert into @tables
SELECT * FROM [fnSplitString] (@TABLENAMES,',')



insert into @option
select * from [fnSplitString] (@options,',')

DECLARE tabcursor CURSOR for
select alltabs.objectid, tab.TableName from @tables tab
join @alltables alltabs
	on tab.Tablename = alltabs.tablename
	and alltabs.schemaname = @schemaname

OPEN tabcursor
FETCH NEXT FROM tabcursor INTO @objid, @tabname
while (@@FETCH_STATUS =0)
BEGIN
	
	insert into @indexstatistics
	exec('SELECT /*ind.object_id AS objectid,*/ ''' +  @tabname + '''[TableName] , 
	Ind.Name,
	indstat.alloc_unit_type_desc,
    /*ind.index_id AS indexid,  */
    /*partition_number AS partitionnum,  */
    avg_fragmentation_in_percent AS frag, ''' + @schemaname + '''  FROM ' + @databasename+ '.' + 'sys.dm_db_index_physical_stats(' + @db_id +' , ' + @objid + ', NULL, NULL , ''Limited'') indstat
	join  ' + @databasename+ '.' + 'Sys.indexes ind
		on ind.index_id = indstat.index_id
		and ind.object_id = indstat.object_id
	where ind.object_id =  ' + @objid +' and avg_fragmentation_in_percent > 0')
	
	

FETCH NEXT FROM tabcursor INTO @objid, @tabname
END
CLOSE tabcursor
Deallocate tabcursor



if exists(select * from @option where ltrim(rtrim(optionname)) in ('Display'))
select @databasename [DBName], schemaname[Schema], tablename [TableName], isnull(indexname, 'There is no index, please create at least a primary key or clustered index on this table') [Index], allotype [Allocation], fragmentationlevel [Fragmentation%] fro
m @indexstatistics

if exists(select * from @option where ltrim(rtrim(optionname)) in ('Execute'))
begin
	declare executeindexes cursor
	for select distinct tablename, indexname, schemaname from @indexstatistics where fragmentationlevel > 0


	open executeindexes
	fetch next from executeindexes into @tabname, @indexname, @schemaname
	while (@@fetch_status = 0)
	begin
		set @command = N'ALTER INDEX ' + @indexname + N' ON ' + @databasename+ '.' + @schemaname + N'.' + @tabname + N' rebuild'; 
		print 'Rebuilding Index - ' + @command + ' '+ cast(getdate() as varchar)
		exec (@command)
		print 'Rebuilt Index - ' + @command + ' '+ cast(getdate() as varchar)
		fetch next from executeindexes into @tabname, @indexname, @schemaname
	end
	CLOSE executeindexes
	Deallocate executeindexes
end
GO