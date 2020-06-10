PRINT 'Started creating Linked Server'
IF NOT EXISTS (select * from sys.servers where name ='REPORTS')
begin
	/****** Object:  LinkedServer [REPORTS]    Script Date: 10/25/2011 15:01:34 ******/
	EXEC master.dbo.sp_addlinkedserver @server = N'REPORTS', @srvproduct=N'sqlserver', @provider=N'SQLNCLI', @datasrc=$(ReportsServer), @catalog=N'DBLog'
	 /* For security reasons the linked server remote logins password is changed with ######## */
	EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'REPORTS',@useself=N'True',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL

	EXEC master.dbo.sp_serveroption @server=N'REPORTS', @optname=N'collation compatible', @optvalue=N'false'

	EXEC master.dbo.sp_serveroption @server=N'REPORTS', @optname=N'data access', @optvalue=N'true'

	EXEC master.dbo.sp_serveroption @server=N'REPORTS', @optname=N'dist', @optvalue=N'false'

	EXEC master.dbo.sp_serveroption @server=N'REPORTS', @optname=N'pub', @optvalue=N'false'

	EXEC master.dbo.sp_serveroption @server=N'REPORTS', @optname=N'rpc', @optvalue=N'true'

	EXEC master.dbo.sp_serveroption @server=N'REPORTS', @optname=N'rpc out', @optvalue=N'true'

	EXEC master.dbo.sp_serveroption @server=N'REPORTS', @optname=N'sub', @optvalue=N'false'

	EXEC master.dbo.sp_serveroption @server=N'REPORTS', @optname=N'connect timeout', @optvalue=N'0'

	EXEC master.dbo.sp_serveroption @server=N'REPORTS', @optname=N'collation name', @optvalue=null

	EXEC master.dbo.sp_serveroption @server=N'REPORTS', @optname=N'lazy schema validation', @optvalue=N'false'

	EXEC master.dbo.sp_serveroption @server=N'REPORTS', @optname=N'query timeout', @optvalue=N'0'

	EXEC master.dbo.sp_serveroption @server=N'REPORTS', @optname=N'use remote collation', @optvalue=N'true'

	EXEC master.dbo.sp_serveroption @server=N'REPORTS', @optname=N'remote proc transaction promotion', @optvalue=N'true'

	PRINT 'Created Linked Server'

END