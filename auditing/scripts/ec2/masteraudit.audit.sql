/*
Execute in sqlcmd mode only
*/

USE [master]
GO

/*
:setvar AUDITPATH "c:\auditdata"
:setvar AUDITNAME "chcmasteraudit"
*/

/****** Object:  Audit [testauditfile]    Script Date: 6/15/2020 2:45:48 AM ******/
if not exists(select * from sys.server_audits where name='$(AUDITNAME)')
begin
	CREATE SERVER AUDIT $(AUDITNAME)
	TO FILE 
	(	FILEPATH = '$(AUDITPATH)'
		,MAXSIZE = 20 MB
		,MAX_ROLLOVER_FILES = 2147483647
		,RESERVE_DISK_SPACE = OFF
	)
	WITH
	(	QUEUE_DELAY = 1000
		,ON_FAILURE = CONTINUE
	)

	ALTER SERVER AUDIT $(AUDITNAME) WITH (STATE = ON)
END
