create procedure dblog.sp_exportRequestsAndUpdate
as
declare @exportto datetime
select @exportto =  dateadd(MINUTE, -7, getdate())

SELECT 
	[session_id]
      ,[request_id]
      ,[command]
      ,[start_time]
      ,[status]
      ,[sql_handle]
      ,[plan_handle]
      ,[object_id]
      ,[wait_time]
      ,[wait_type]
      ,[wait_resource]
      ,[last_wait_type]
      ,[cpu_time]
      ,[total_elapsed_time]
      ,[reads]
      ,[writes]
      ,[text]
      ,[query_plan]
      ,[databasename]
      ,[logical_reads]
      ,[ClientIP]
      ,[MemoryMB]
      ,[TempDBMB]
      ,[Statement_StartOffSet]
      ,[Statement_EndOffSet]
      ,[ServerName]
      ,[collectiondate]
  FROM [DBLOG].[DBLog].[Requests]
  where exportstatus = 0
  and collectiondate <= @exportto


  -- mark for cleanup
  update [DBLOG].[DBLog].[Requests]
  set exportstatus = 1
  where exportstatus = 0 and collectiondate <= @exportto

  GO