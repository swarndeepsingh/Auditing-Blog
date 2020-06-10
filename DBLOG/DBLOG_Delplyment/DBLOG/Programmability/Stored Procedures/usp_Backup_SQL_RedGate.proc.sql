create procedure dblog.usp_Backup_SQL_RedGate @backupType varchar(5)
	, @dbname varchar(512), @fullfilename varchar(8000)
	, @compression char(1) = 4, @filename varchar(4000)
	,@sqlout varchar(8000) output
as
 set @sqlout = N'-SQL "Backup ' + case @backuptype when 'D' then 'Database' when 'I' then 'Database' else 'Log' end    
 + ' [' + @dbname + '] To DISK=''' + @fullfilename +  ''' WITH '+ case @backuptype   
 when 'I' then 'DIFFERENTIAL, ' else ' ' end     +' 
   NAME= ''' + @filename + ''''
  + ', DESCRIPTION =''<AUTO>'', PASSWORD =''<ENCRYPTEDPASSWORD>cgM6QthDbms=</ENCRYPTEDPASSWORD>'',  
  KEYSIZE=128, COMPRESSION=' + @compression + ', THREADCOUNT = 23"'
  -- <N0tBl4nk>
 GO  