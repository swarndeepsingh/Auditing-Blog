create proc DBLOG.usp_getServerBasicProperties
as
declare @servername varchar(512), @iscluster bit, @activeNode varchar(512), @version varchar(255)
select @version = @@version
-- get server name
select @servername = @@SERVERNAME
-- check if cluster
set @iscluster = 0
if exists(select 1 from sys.dm_os_cluster_nodes)
	set @iscluster = 1

-- get the current node
SELECT @activeNode = cast(SERVERPROPERTY('ComputerNamePhysicalNetBIOS')  as varchar(512)) 

select 'Server Name' [PropertyName], @servername  + '(Version : ' + @version  + ')' [PropertyValue]
union all
select 'Is Server Cluster', case @iscluster when 0 then '-NA-' else 'Yes, Server is Cluster' end
/*union all
Select 'Active Node', @activeNode*/
union all
select 'Cluster Node', NodeName from sys.dm_os_cluster_nodes
GO