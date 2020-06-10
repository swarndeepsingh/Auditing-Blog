use DBLOG
GO

create procedure dblog.sp_ClearRequests
as

Delete from DBLOG.requests
where ExportStatus = 1
and collectiondate < dateadd(MINUTE, 30, getdate())
GO


