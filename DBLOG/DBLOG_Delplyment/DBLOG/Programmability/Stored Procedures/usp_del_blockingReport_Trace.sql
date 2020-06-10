SET QUOTED_IDENTIFIER ON
GO
CREATE proc [DBLog].[usp_del_blockingReport_Trace] @filename nvarchar(256)
as
SET NOCOUNT ON
declare @sqltext nvarchar(500)
	if (select value from sys.configurations where name = 'show advanced options' )= 0
	exec sp_configure 'show advanced options',1

	exec sp_configure 'xp_cmdshell', 1
	reconfigure

set @sqltext = 'master.dbo.xp_cmdshell ''DEL "' + @filename + '."'''
EXEC(@sqltext)
GO