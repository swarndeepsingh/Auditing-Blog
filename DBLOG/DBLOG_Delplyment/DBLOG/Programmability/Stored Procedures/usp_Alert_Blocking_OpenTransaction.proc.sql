CREATE proc [DBLog].[usp_Alert_Blocking_OpenTransaction] @profile varchar(50), @recipeints varchar(200)
as
Print 'Disabled this SP, as this is being taken care by DBLOG now'
/*
declare @tableHtml varchar(max), 
        @spid int, 
		@subject varchar(2000),
		@Blocked int
declare @SPIDs table
(spid int,
blocked int,
DBName varchar(50),
last_batch datetime,
open_tran int,
[hostname] varchar(50),
[program_name] varchar(100),
nt_username varchar(50),
loginname varchar(100),
servername varchar(100))

insert into @SPIDs
select distinct spid,blocked,db_name(dbid) [dbname],last_batch,open_tran,hostname,program_name
,nt_username,loginame, @@servername from master..sysprocesses
where (open_tran = 1 or blocked > 0) and loginame not like '%sql-svc%' and last_batch <= DATEADD(MINUTE,-5,GETDATE())
and DB_NAME(dbid) not in ('MSDB', 'Master', 'distribution','MDW')

declare SPID_Scan cursor for
select spid,blocked from @SPIDs order by spid

open SPID_Scan

FETCH NEXT from SPID_Scan
INTO @spid,@Blocked

while @@FETCH_STATUS = 0
BEGIN

      set @tableHtml= 
      '<font face="verdana"><H3>Open Transaction Report/Blocking Report</H3><Table border="1">'+
      CAST(
      (select top 1  +
      '@@SPID:!!///'+cast(spid as varchar(10))+'\\\??'+
      '@@Database:!!///'+cast(dbname as varchar(50))+'\\\??'+
      '@@Batch Date:!!///'+cast(last_batch as varchar(100))+'\\\??'+
      '@@*Is Transaction Opened?:!!///'+case when cast(open_tran as varchar(100)) = 1 then 'Yes' else 'NO' end+'\\\??'+
      '@@#Blocking SPID:!!///'+cast(blocked as varchar(10))+'\\\??'+
      '@@Host:!!///'+cast(hostname as varchar(100))+'\\\??'+
      '@@Server:!!///'+servername+'\\\??'+
      '@@Program:!!///'+cast(program_name as varchar(100))+'\\\??'+
      '@@NT User:!!///'+cast(nt_username as varchar(100))+'\\\??'+
      '@@Login:!!///'+cast(loginname as varchar(100))+'\\\??'

      from @spids where spid = @spid)
      as varchar(max))
      +'</Table></font><br><br><p><i><font size="2" face="verdana"><font color="red">*</font> If "Is Transaction Opened" is "Yes", that indicates transaction
      has begun but  not committed or rolled back till yet. If you see more than 1 alerts of same SPID then this is critical and needs to be resolved quickly. <BR>
      <font color="red">#</font> If "Blocking SPID" value is other than 0 then that indicates current SPID has been blocked by "Blocking SPID". If Blocking has been there for more than 10 minutes then this needs to be addressed quickly.</font></p></i>'

 
      set @tableHTML = replace(replace(replace(REPLACE(@tableHTML,'@@','<tr><td><b>'),'!!','</b></td>'),'///','<td>'),'\\\??','</td></tr>')

	  --set @subject = '!!Important - Action Required!! SPID - ' + cast(@spid as varchar(4)) + ' at ' + @@servername + ' reported Blocking or Open Transaction'
      If @Blocked <> 0 
        BEGIN
          set @subject = '!!Important - Action Required!! '  + @@servername + ' : Blocking SPID - ' + cast(@Blocked as varchar(4))+ ' On SPID - ' + cast(@spid as varchar(4))  
        END
      Else
        BEGIN
          set @subject = '!!Important - Action Required!!  '  + @@servername + ' : Open Transaction SPID - ' + cast(@spid as varchar(4))
        END


	  select @tableHtml
      exec msdb.dbo.sp_send_dbmail     
      @profile_name=@profile,    
      @recipients=@recipeints,    
      @subject=@subject,    
      @body_format = 'HTML',    
      @body=@tableHTML  
      --@from_address = @subject 

      FETCH NEXT from SPID_Scan
      INTO @spid,@Blocked
END
close SPID_Scan
deallocate SPID_Scan
*/