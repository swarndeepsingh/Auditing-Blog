create procedure dblog.usp_Backup_SQL_LiteSpeed @backupType varchar(5)
	, @dbname varchar(512), @fullfilename varchar(8000)
	, @compression char(1) = 5, @filename varchar(4000)
	,@sqlout varchar(8000) output
as
 set @sqlout = N'execute master.dbo.xp_backup_' + case @backuptype when 'D' then 'Database' when 'I' then 'Database' else 'Log' end    
 + ' @database = ''' + @dbname + '''
 , @filename=''' + @fullfilename +  ''''+
case @backuptype    when 'I' then ', @with = ''DIFFERENTIAL''' else ' ' end    + 
 ', @encryptionkey =''N0tBl4nk'',  
  @cryptlevel=6, 
  @COMPRESSIONLEVEL=' + @compression
  -- <N0tBl4nk>