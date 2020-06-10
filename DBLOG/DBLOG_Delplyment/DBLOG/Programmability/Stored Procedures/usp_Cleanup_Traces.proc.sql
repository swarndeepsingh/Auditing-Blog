CREATE procedure [DBLog].[usp_Cleanup_Traces] @tracename varchar(255)
as

declare @version varchar(500)
select @version=cast(SERVERPROPERTY('productversion') as varchar(10))

if @version like '8.%'
begin
	EXEC [DBLog].usp_del_osfile @tracename
	return
end
	
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
		
			EXEC [DBLOG].usp_del_osfile @tracename


-- EXEC sp_configure 'xp_cmdshell', 0
-- reconfigure with override

-- EXEC sp_configure 'Show Advanced Options', 0
-- reconfigure with override