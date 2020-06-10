


alter procedure [DBLog].[usp_GetRequests]
as
declare @requests TABLE (
	[session_id] [smallint] NOT NULL,
	[request_id] int null,
	[command] [nvarchar](32) NOT NULL,
	[start_time] [datetime] NOT NULL,
	[status] [nvarchar](30) NOT NULL,
	[sql_handle] [varbinary](64) NULL,
	[plan_handle] [varbinary](64) NULL,
	[object_id] int  null,
	[wait_time] [int] NOT NULL,
	[wait_type] [nvarchar](60) NULL,
	[wait_resource] [nvarchar](256) NOT NULL,
	[last_wait_type] [nvarchar](60) NOT NULL,
	[cpu_time] [int] NOT NULL,
	[total_elapsed_time] [int] NOT NULL,
	[reads] [bigint] NOT NULL,
	[writes] [bigint] NOT NULL,
	[text] [nvarchar](max) NULL,
	[query_plan] [xml] NULL,
	[databasename] [nvarchar](128) NOT NULL,
	[logical_reads] [bigint] NOT NULL,
	/*added new*/
	[ClientIP] [varchar](15) NULL,
	[MemoryMB] numeric(20,2) NULL,
	[TempDBMB] Numeric(20,2) null,
	[startoffset] int null,
	[endoffset] int null,
	/**/
	[ServerName] [nvarchar](128) NULL
	
)

insert into @requests
select 
req.session_id, 
req.request_id,
req.command, 
req.start_time, 
req.status,
req.sql_handle, 

req.plan_handle, 
dest.objectid,
req.wait_time, 
req.wait_type, 
req.wait_resource, 
req.last_wait_type,
req.cpu_time, 
req.total_elapsed_time, 
req.reads, 
req.writes,
dest.text, 
--'StoppedSince 5/23/2016bySwarndeep' [Text],
isnull(cast(deqp.query_plan as varchar(max)), 'NA'), 
db_name(req.database_id) [DBName], 
req.logical_reads,
[dec].client_net_address,
req.granted_query_memory * 1.0 /128 [memoryMB],
(ddssu.internal_objects_alloc_page_count + ddtsu.task_alloc)*1.0/128 [TempDBMB],
--(ddssu.internal_objects_dealloc_page_count + ddtsu.task_dealloc) [DeAllocated],
  /*[TempDBMB],*/
req.statement_start_offset,
req.statement_end_offset,
@@SERVERNAME [ServerName] 
from sys.dm_exec_requests req
cross apply sys.dm_exec_sql_text (req.sql_handle) dest
cross apply sys.dm_exec_query_plan(req.plan_handle) deqp
inner join sys.dm_exec_connections [dec]
	on dec.connection_id = req.connection_id
inner join sys.dm_db_session_space_usage ddssu
	on ddssu.session_id = req.session_id
INNER JOIN 
       (
           SELECT 
               session_id,  
               SUM(internal_objects_alloc_page_count)      AS task_alloc, 
               SUM (internal_objects_dealloc_page_count)    AS task_dealloc  
           FROM sys.dm_db_task_space_usage 
           GROUP BY session_id
       ) AS ddtsu
 on ddssu.session_id =  ddtsu.session_id	
where req.status in ('suspended', 'runnable', 'running')
and dest.[text] not like '%usp_getwaitstats%'
and dest.[text] not like '%usp_GetRequests%'
and cast(deqp.query_plan as varchar(max)) is not null
/*
select 
req.session_id, 
req.request_id,
req.command, 
req.start_time, 
req.status,
req.sql_handle, 
req.plan_handle, 
dest.objectid,
req.wait_time, 
req.wait_type, 
req.wait_resource, 
req.last_wait_type,
req.cpu_time, 
req.total_elapsed_time, 
req.reads, 
req.writes,
dest.text, 
isnull(cast(deqp.query_plan as varchar(max)), 'NA'), 
db_name(req.database_id) [DBName], 
req.logical_reads,
[dec].client_net_address,
req.granted_query_memory * 1.0 /128 [memoryMB],
SUM(ddtsu.user_objects_alloc_page_count + ddtsu.user_objects_dealloc_page_count + ddtsu.internal_objects_alloc_page_count + ddtsu.internal_objects_dealloc_page_count) * 1.0 /128 
/*from sys.dm_db_task_space_usage tsu where tsu.exec_context_id = ddtsu.exec_context_id and tsu.session_id = req.session_id and req.request_id = tsu.request_id and req.database_id = tsu.database_id*/
 [TempDBMB],
req.statement_start_offset,
req.statement_end_offset,
@@SERVERNAME [ServerName] 
from sys.dm_exec_requests req
outer apply sys.dm_exec_sql_text (req.sql_handle) dest
outer apply sys.dm_exec_query_plan(req.plan_handle) deqp
inner join sys.dm_exec_connections [dec]
	on dec.connection_id = req.connection_id
inner join sys.dm_db_task_space_usage ddtsu
	on ddtsu.session_id = req.session_id
	and ddtsu.request_id = req.request_id	
	--and ddtsu.database_id = req.database_id -- Fix 442017
where req.status in ('suspended', 'runnable', 'running')
and dest.[text] not like '%usp_getwaitstats%'
and dest.[text] not like '%usp_GetRequests%'
group by req.session_id, 
req.request_id,
req.command, 
req.start_time, 
req.status,
req.sql_handle, 
req.plan_handle, 
dest.objectid,
req.wait_time, 
req.wait_type, 
req.wait_resource, 
req.last_wait_type,
req.cpu_time, 
req.total_elapsed_time, 
req.reads, 
req.writes,
dest.text, 
isnull(cast(deqp.query_plan as varchar(max)), 'NA'), 
db_name(req.database_id) , 
req.logical_reads,
[dec].client_net_address,
req.granted_query_memory * 1.0 /128,
req.statement_start_offset,
req.statement_end_offset/*,
@@SERVERNAME */
*/



declare @sessionid smallint, @request_id int, @starttime datetime, @collectiontime datetime = getdate()
declare @sqlhandle varbinary(64), @startoffset int, @endoffset int



declare request_cur cursor fast_forward for
select session_id, request_id, start_time, [sql_handle], startoffset, endoffset from @requests
open request_cur
fetch next from request_cur 
into @sessionid, @request_id, @starttime, @sqlhandle, @startoffset, @endoffset
while (@@FETCH_STATUS = 0)
begin


	--select * from @requests
	if exists(
	select 1 from [dblog].[requests] where session_id = @sessionid and start_time = @starttime and request_id = @request_id and [sql_handle] = @sqlhandle and Statement_StartOffSet = @startoffset and Statement_EndOffSet = @endoffset
	)
	begin
		delete from [dblog].[requests] where session_id = @sessionid and start_time = @starttime and request_id = @request_id and [sql_handle] = @sqlhandle and Statement_StartOffSet = @startoffset and Statement_EndOffSet = @endoffset
		insert into [dblog].[requests]
		select *, @collectiontime,0 from @requests where session_id = @sessionid and start_time = @starttime and request_id = @request_id and [sql_handle] = @sqlhandle and startoffset = @startoffset and endoffset = @endoffset


		--select 'Existing'
		--select *, @collectiontime,0 from @requests where session_id = @sessionid and start_time = @starttime and request_id = @request_id and [sql_handle] = @sqlhandle
	end

	if not exists(select 1 from [dblog].[requests] where session_id = @sessionid and start_time = @starttime and request_id = @request_id and [sql_handle] = @sqlhandle and Statement_StartOffSet = @startoffset and Statement_EndOffSet = @endoffset)
	begin		
		insert into [dblog].[requests]
		select *, @collectiontime,0 from @requests where session_id = @sessionid and start_time = @starttime and request_id = @request_id and [sql_handle] = @sqlhandle and startoffset = @startoffset and endoffset = @endoffset

		--select 'New'
		--select *, @collectiontime,0 from @requests where session_id = @sessionid and start_time = @starttime and request_id = @request_id and [sql_handle] = @sqlhandle
	end

fetch next from request_cur 
into @sessionid, @request_id, @starttime, @sqlhandle, @startoffset, @endoffset
end
close request_cur
deallocate request_cur

GO