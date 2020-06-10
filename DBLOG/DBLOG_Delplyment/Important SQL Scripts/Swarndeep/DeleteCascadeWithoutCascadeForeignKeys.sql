declare @base_schema_name varchar(100), @base_table_name varchar(200), @base_criteria nvarchar(1000)
select @base_schema_name = 'bk', @base_table_name = 'organisation', @base_criteria ='organisationid=79'
    declare @to_delete table (
        id int identity(1, 1) primary key not null,
        criteria nvarchar(1000) not null,
		schemaname varchar(200) not null,
        table_name varchar(200) not null,
        processed bit not null,
        delete_sql varchar(1000)
    )
    insert into @to_delete (criteria, schemaname, table_name, processed) values (@base_criteria,@base_schema_name, @base_table_name, 0)
    declare @id int, @criteria nvarchar(1000), @schema_name varchar(200), @table_name varchar(200)
    while exists(select 1 from @to_delete where processed = 0) 
	begin
        select top 1 @id = id, @criteria = criteria, @table_name = table_name, @schema_name = schemaname from @to_delete where processed = 0 order by id desc

        insert into @to_delete (criteria, schemaname, table_name, processed)
            select referencing_column.name + ' in (select [' + referenced_column.name + '] from [' + @schema_name + '].[' + @table_name +'] where ' + @criteria + ')',
                schema_name(referencing_table.schema_id), referencing_table.name,
                0
            from  sys.foreign_key_columns fk
                inner join sys.columns referencing_column on fk.parent_object_id = referencing_column.object_id 
                    and fk.parent_column_id = referencing_column.column_id 
                inner join  sys.columns referenced_column on fk.referenced_object_id = referenced_column.object_id 
                    and fk.referenced_column_id = referenced_column.column_id 
                inner join  sys.objects referencing_table on fk.parent_object_id = referencing_table.object_id 
                inner join  sys.objects referenced_table on fk.referenced_object_id = referenced_table.object_id 
                inner join  sys.objects constraint_object on fk.constraint_object_id = constraint_object.object_id
            where referenced_table.name = @table_name 
				and referenced_table.schema_id = schema_id(@base_schema_name)
                and referencing_table.object_id != referenced_table.object_id
        update @to_delete set
            processed = 1
        where id = @id
    end
    select 'print ''deleting from ' + schemaname + '.' + table_name + '...''; delete from [' + schemaname + '].[' + table_name + '] where ' + criteria from @to_delete order by id desc

