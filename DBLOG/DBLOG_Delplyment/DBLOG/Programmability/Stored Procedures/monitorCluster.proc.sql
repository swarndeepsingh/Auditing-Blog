CREATE proc [DBLog].[monitorCluster]
as
Declare @var1 varchar(30)
declare @var2 varchar(30)
declare @msgbody varchar(5000)
declare @msgsubject varchar(500)
SELECT @var1= PREVIOUS_ACTIVE_NODE FROM DBLOG.CLUSTERFAILOVERMONITOR

CREATE TABLE PHYSICALHOSTNAME
(
VALUE VARCHAR(30),
CURRENT_ACTIVE_NODE VARCHAR(30)
)

INSERT INTO PHYSICALHOSTNAME
select 'CurrentNode',convert(varchar(30),SERVERPROPERTY('ComputerNamePhysicalNetBIOS'))



SELECT @VAR2=CURRENT_ACTIVE_NODE FROM PHYSICALHOSTNAME

if @VAR1<>@VAR2

Begin
	set @msgbody = 'Cluster failover has occured for instance ' + @@servername --+ '. Below given are the previous and current active nodes.'
	set @msgsubject = 'Failover occurrence notification - ' + @@SERVERNAME + '. Current Node: ' + @var2
	print 'Active node changed'

	EXEC msdb..sp_send_dbmail @profile_name='DBAMail',
	@recipients='swarndeep.singh@ebix.com; sqlhelp@ebix.com; NetOps.EbixExchange@ebix.com; aarora@ebix.com',
	@subject=@msgsubject,
	@body=@msgbody
	--@QUERY='SET NOCOUNT ON;SELECT PREVIOUS_ACTIVE_NODE FROM DBLOG.CLUSTERFAILOVERMONITOR;SELECT CURRENT_ACTIVE_NODE FROM PHYSICALHOSTNAME;SET NOCOUNT oFF'

update DBLog.CLUSTERFAILOVERMONITOR set PREVIOUS_ACTIVE_NODE=@VAR2

End

--else if @VAR1=@VAR2

--Begin
--	set @msgbody = 'Information Only ' + @@servername --+ '. Below given are the previous and current active nodes.'
--	set @msgsubject = 'Failover occurrence notification - ' + @@SERVERNAME + '. Current Node: ' + @var2
	
--	EXEC msdb..sp_send_dbmail @profile_name='DBAMail',
--	@recipients='swarndeep.singh@ebix.com; sqlhelp@ebix.com; NetOps.EbixExchange@ebix.com; aarora@ebix.com' ,
--	@subject=@msgsubject,
--	@body=@msgbody
--	--@QUERY='SET NOCOUNT ON;SELECT PREVIOUS_ACTIVE_NODE FROM DBLOG.CLUSTERFAILOVERMONITOR;SELECT CURRENT_ACTIVE_NODE FROM PHYSICALHOSTNAME;SET NOCOUNT oFF'

--update DBLog.CLUSTERFAILOVERMONITOR set PREVIOUS_ACTIVE_NODE=@VAR2

--End

DROP TABLE PHYSICALHOSTNAME