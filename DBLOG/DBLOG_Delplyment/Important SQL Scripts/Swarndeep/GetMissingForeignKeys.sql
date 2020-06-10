SELECT schema_name(t.schema_id) [ForeignSchema], t.name [ForeignTable], c.name [ForeignColumn], substring(c.name, 1 ,len(c.name)-2) [ParentTable]
, 'Alter Table ' 
	+ schema_name(t.schema_id) + '.' + 
		t.name + ' ADD CONSTRAINT FK_' + 
			t.name + '_' +  
			substring(c.name, 1 ,len(c.name)-2) + 
			' FOREIGN KEY ' +
			' (' + c.name + ') REFERENCES ' + 
			schema_name(t.schema_id)  + 
			'.' + 
			substring(c.name, 1 ,len(c.name)-2) + 
			'(' + parentcolumn.name + 
			');'
, schema_name(parenttable.schema_id), parenttable.name, parentcolumn.name
,  ' alter table '  + schema_name(t.schema_id)  + 
			'.' + 
			substring(c.name, 1 ,len(c.name)-2) +  ' drop constraint ' + 'FK_' + 			t.name + '_' +  			substring(c.name, 1 ,len(c.name)-2) + ';'
FROM sys.columns c
INNER JOIN sys.tables t
	ON t.object_id = c.object_id
INNER JOIN sys.indexes i
	ON i.object_id = t.object_id
LEFT JOIN sys.foreign_key_columns fkc_Parent
	ON fkc_Parent.parent_column_id = c.column_id
	AND fkc_Parent.parent_object_id = c.object_id
LEFT JOIN sys.foreign_key_columns fkc_Referenced
	ON fkc_Referenced.Referenced_column_id = c.column_id
	AND fkc_Referenced.Referenced_object_id = c.object_id
LEFT JOIN sys.index_columns ic
	ON ic.index_id = i.index_id
	AND ic.object_id = t.object_id
	AND ic.column_id = c.column_id
join sys.objects parenttable
	on parenttable.name = substring(c.name, 1 ,len(c.name)-2) 
join sys.columns parentcolumn
	--on parentcolumn.column_id = ic.column_id
	on parentcolumn.object_id = parenttable.object_id
join sys.indexes parentidx
	on parentidx.object_id = parentcolumn.object_id
	and parentidx.is_primary_key = 1
join sys.index_columns parentic
	on parentic.index_id = parentidx.index_id
	and parentic.object_id = parentcolumn.object_id
	and parentic.column_id = parentcolumn.column_id
WHERE fkc_Referenced.constraint_object_id IS NULL
	AND fkc_Parent.constraint_column_id IS NULL
	AND ic.index_column_id IS NULL
	AND c.name LIKE '%id'
	AND i.is_primary_key = 1
	--and schema_name(t.schema_id) = 'bk'
	and parenttable.schema_id = t.schema_id
ORDER BY schema_name(t.schema_id), t.name, c.name