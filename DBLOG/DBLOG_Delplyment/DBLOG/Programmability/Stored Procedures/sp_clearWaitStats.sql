use DBLOG
GO

create procedure dblog.sp_clearWaitStats
as

Delete from DBLOG.WaitStats
where ExportStatus = 1
GO