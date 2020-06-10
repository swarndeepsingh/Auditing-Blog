CREATE proc [DBLog].[usp_StopTrace] @tracename varchar(255)
as
declare @traceid int
declare @tracefilename varchar(2000), @error varchar(500)

SELECT top 1 @tracefilename = cast(value as varchar(256)), @traceid = traceid
 FROM ::fn_trace_getinfo(0) where cast(value as varchar(256)) 
like '%' + @tracename + '%' and property = 2

if @traceid is null 
begin
	set @error ='No Active Trace Found for ' + @tracename + '. Proceeding without stopping any traces.'
	raiserror(@error, 10 ,1)
	return 
end

	--Stop the trace here
	exec sp_trace_setstatus  @traceid, 0 
	--Delete the trace here
	exec sp_trace_setstatus   @traceid, 2 
	
update trace_info
set active = 0
where tracefile = @tracefilename