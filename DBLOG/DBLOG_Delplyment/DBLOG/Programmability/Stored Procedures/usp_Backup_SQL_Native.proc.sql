create procedure dblog.usp_Backup_SQL_Native @backupType varchar(5)
	, @dbname varchar(512), @fullfilename varchar(8000)
	, @compression char(1), @filename varchar(4000)
	,@sqlout varchar(8000) output
as
 set @sqlout = N'Backup ' + case @backuptype when 'D' then 'Database' when 'I' then 'Database' else 'Log' end    
 + ' [' + @dbname + '] To DISK=''' + @fullfilename +  ''' WITH '+ case @backuptype   
 when 'I' then 'DIFFERENTIAL, ' else ' ' end     
  + 'FORMAT,  SKIP, REWIND, NOUNLOAD,'   
 + case @compression when 1 then 'COMPRESSION,' else ' ' end +  
  '  NAME= ''' + @filename +''''  
  
  
 GO