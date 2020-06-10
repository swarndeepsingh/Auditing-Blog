create proc DBLOG.usp_getServerMemoryStatus
as
select unpivoted.Parameter, unpivoted.result
 from  sys.dm_os_sys_memory s
 outer apply (
	 Select 'Memory Status', system_memory_state_desc union all
    select 'Total Server Memory', cast(total_physical_memory_kb/1024/1024 as nvarchar(50)) + ' GB' union all
    select 'Available Server Memory', cast(available_physical_memory_kb/1024/1024 as nvarchar(50)) + ' GB'  union all
    select 'Total Page Memory', cast(total_page_file_kb/1024/1024 as nvarchar(50)) + ' GB'  union all
    select 'Available Page Memory', cast(available_page_file_kb/1024/1024 as nvarchar(50)) + ' GB' 
   
 ) unpivoted( Parameter, result )
 union all
 select  'Memory Assigned to SQL',cast(cntr_value/1024/1024 as nvarchar(50)) + ' GB'  [SQL_Assigned_Memory] from sys.dm_os_performance_counters where object_name = 'SQLServer:Memory Manager' and counter_name = 'Total Server Memory (KB)'
 GO