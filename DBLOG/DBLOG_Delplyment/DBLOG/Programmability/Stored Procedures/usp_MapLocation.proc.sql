CREATE proc [DBLog].[usp_MapLocation] @locationID int, @location varchar(4000) output
as
declare @message varchar(8000), @transferid int
,@locationPath varchar(4000), @MapName varchar(50), @UName varchar(500), @password varchar(8000)
,@passcode varchar(500), @ismap bit, @sql varchar(8000)

select @locationPath=locationpath, @ismap=ismapped, @mapname=mapname
, @uname = username, @password=pword from dblog.location_details
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






	if (@UName is null or @password is null)
	begin
		set @sql = 'net use ' + @mapname + ' ' + @locationPath
		EXEC xp_cmdshell @sql
	end
	else
	begin
		select @passcode = propertyvalue from DBLog.MiscProperties 
		where propertyname = 'Location_Password_1'
		
		
		set @password = convert(varchar,DECRYPTBYPASSPHRASE(@passcode,@password))
		
		set @sql = 'net use ' + @mapname + ' ' + @locationPath + ' ' + @password + ' /user:' + @UName
		EXEC xp_cmdshell @sql
	end

 
-- EXEC sp_configure 'xp_cmdshell', 0  
-- reconfigure with override  
  
-- EXEC sp_configure 'Show Advanced Options', 0  
-- reconfigure with override


end
set @location=@locationPath

--return @location