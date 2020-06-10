IF OBJECT_ID (N'dbo.index_included_reset_name', N'FN') IS NOT NULL  
    DROP FUNCTION dbo.index_included_reset_name;  
GO  


create function dbo.index_included_reset_name (@stringToSplit VARCHAR(MAX), @sepchar char(1))
returns varchar(500)
as
BEGIN
DECLARE @name NVARCHAR(255)
 DECLARE @pos INT
 declare @returnlist varchar(500)
  
    select @stringtosplit = @stringToSplit + '_'

 WHILE CHARINDEX(@sepchar, @stringToSplit) > 0
 BEGIN
  SELECT @pos  = CHARINDEX('_', @stringToSplit)  
  SELECT @name = SUBSTRING(@stringToSplit, 1, @pos-1)


  select @returnlist = isnull(@returnlist,'') +  left(@name, 2) + right(@name, 1) + '_'
  SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
end
  return substring(@returnlist, 1, len(@returnlist) -1)
END
GO

declare @dbname varchar(255)
declare checkind cursor FOR
select name from sys.databases 
where name not in ('master','model','msdb','tempdb', 'MDW', 'DBLOG')

Open checkind

fetch next from checkind
INTO @dbname
while @@FETCH_STATUS = 0
BEGIN

	SELECT TOP 50
	db_name(dm_mid.database_id) AS DatabaseName,
	dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) Avg_Estimated_Impact,
	dm_migs.last_user_seek AS Last_User_Seek,
	OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) AS [TableName],
	'USE ' + db_name(dm_mid.database_id)  +  '; ' + 'CREATE INDEX [IDX_NC_' + OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) + '_'
	+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns,''),', ','_'),'[',''),']','') 
	+ CASE
	WHEN dm_mid.equality_columns IS NOT NULL
	AND dm_mid.inequality_columns IS NOT NULL THEN '_'
	ELSE ''
	END
	+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns,''),', ','_'),'[',''),']','')
	+ '_k_' + dbo.index_included_reset_name(REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.included_columns,''),', ','_'),'[',''),']',''), '_')
	+ ']'
	+ ' ON ' + dm_mid.statement
	+ ' (' + ISNULL (dm_mid.equality_columns,'')
	+ CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns 
	IS NOT NULL THEN ',' ELSE
	'' END
	+ ISNULL (dm_mid.inequality_columns, '')
	+ ')'
	+ ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '') + 'WITH (fillfactor=90) on FG_' + db_name(dm_mid.database_id) + '_indexes' AS Create_Statement
	FROM sys.dm_db_missing_index_groups dm_mig
	INNER JOIN sys.dm_db_missing_index_group_stats dm_migs
	ON dm_migs.group_handle = dm_mig.index_group_handle
	INNER JOIN sys.dm_db_missing_index_details dm_mid
	ON dm_mig.index_handle = dm_mid.index_handle
	WHERE dm_mid.database_ID = DB_ID(@dbname)
	ORDER BY Avg_Estimated_Impact DESC
	fetch next from checkind
	INTO @dbname
END
CLOSE checkind
deallocate checkind