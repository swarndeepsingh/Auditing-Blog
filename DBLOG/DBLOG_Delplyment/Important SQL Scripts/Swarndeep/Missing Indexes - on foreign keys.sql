IF OBJECT_ID (N'dbo.getColumnName', N'FN') IS NOT NULL  
    DROP FUNCTION dbo.getColumnName;  
GO  


create function dbo.getColumnName (@objectid int, @columnid int)
returns varchar(256)
as
BEGIN
declare @columname varchar(256)
select @columname = name from sys.columns where object_id = @objectid and column_id = @columnid
return @columname
END
GO



select
'USE ' + db_name(db_id())  +  '; ' + 'CREATE INDEX [IDX_NC_' + OBJECT_NAME(fkc.parent_OBJECT_ID,db_id()) + '_'
+ REPLACE(REPLACE(REPLACE(ISNULL(dbo.getcolumnname(fkc.parent_object_id, fkc.parent_column_id),''),', ','_'),'[',''),']','') 
+ ']'

+ ' ON ' + db_name(db_id()) + '.' +  sch.name + '.' + obj.name 
+ ' ([' + ISNULL (REPLACE(REPLACE(REPLACE(ISNULL(dbo.getcolumnname(fkc.parent_object_id, fkc.parent_column_id),''),', ','_'),'[',''),']','') ,'')
+  ']) WITH (fillfactor=90) on FG_' + db_name(db_id()) + '_indexes' AS Create_Statement,
 object_name(fkc.parent_object_id),   dbo.getcolumnname(fkc.parent_object_id, fkc.parent_column_id) columnname, ic.index_column_id, fkc.parent_column_id, * from sys.index_columns ic
right outer join sys.foreign_key_columns fkc
	on fkc.parent_object_id = ic.object_id
	and fkc.parent_column_id = ic.column_id
join sys.objects obj
	on obj.object_id = fkc.parent_object_id
join sys.schemas sch
	on obj.schema_id = sch.schema_id
where ic.column_id is null