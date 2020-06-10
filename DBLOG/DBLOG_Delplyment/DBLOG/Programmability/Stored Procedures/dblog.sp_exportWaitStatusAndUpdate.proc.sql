create procedure dblog.sp_exportWaitStatusAndUpdate
as
declare @exportto datetime
select @exportto =  dateadd(MINUTE, -7, getdate())

SELECT 
		@@servername [Servername]
		,[WaitType]
      ,[wait_S]
      ,[Resource_S]
      ,[Signal_S]
      ,[WaitCount]
      ,[Avg_Wait_S]
      ,[Avg_Resource_S]
      ,[Avg_Signal_S]
      ,[CaptureDate]
  FROM [DBLOG].[DBLog].[WaitStats]
  where exportstatus = 0
  and capturedate <= @exportto


  -- mark for cleanup
  update [DBLOG].[DBLog].[WaitStats]
  set exportstatus = 1
  where exportstatus = 0 and capturedate <= @exportto

  GO