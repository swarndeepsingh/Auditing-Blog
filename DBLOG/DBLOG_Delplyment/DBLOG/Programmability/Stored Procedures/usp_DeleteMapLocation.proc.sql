CREATE proc [DBLog].[usp_DeleteMapLocation] @locationid int
as
declare @message varchar(8000), @transferid int,  @MapName varchar(50), @sql varchar(500), @ismap bit

--WAITFOR DELAY '0:0:10'
-- Waiting for pending operations to complete

select  @mapname=mapname, @ismap = ismapped
from dblog.location_details
where locationid = @locationID

if @ismap = 1
begin
create table #xp_cmdshell  
(  
name varchar(200),  
minval varchar(1),  
maxval varchar(1),  
configval varchar(1),  
runval varchar(1)  
)  
  
create table #ShowAdvancedOptions  
(  
name varchar(200),  
minval varchar(1),  
maxval varchar(1),  
configval varchar(1),  
runval varchar(1)  
)  
  
insert into #ShowAdvancedOptions  
EXEC sp_configure 'Show Advanced Options'  
if (select configval from #ShowAdvancedOptions) = 0  
begin  
 EXEC sp_configure 'Show Advanced Options', 1  
 reconfigure with override    
end  
   
insert into #XP_cmdshell  
EXEC sp_configure 'xp_cmdshell'  
if (select configval from #XP_cmdshell) = 0  
begin  
 EXEC sp_configure 'xp_cmdshell', 1  
 reconfigure with override  
   
end   




set @sql = 'net use ' + @mapname + ' /delete'
EXEC xp_cmdshell @sql
  
  
-- EXEC sp_configure 'xp_cmdshell', 0  
-- reconfigure with override  
  
-- EXEC sp_configure 'Show Advanced Options', 0  
-- reconfigure with override

end