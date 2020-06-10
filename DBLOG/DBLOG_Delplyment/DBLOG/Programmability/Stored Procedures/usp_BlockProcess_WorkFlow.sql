SET QUOTED_IDENTIFIER ON
GO
CREATE proc [DBLog].[usp_BlockProcess_WorkFlow] @status int
as
set nocount on
-- @status = 1 "Reset the trace into new file"
-- @status = 0 "Stop trace after importing"
declare @path nvarchar(256)

declare @version int
declare @productversion varchar(20)
select @productversion = cast(serverproperty('productversion') as varchar(20))


select @version= substring(@productversion,0,charindex('.',@productversion,0))

if (@version > 9)
begin
--Step 1:
-- Import existing trace and save the path into @path variable
exec dblog.usp_import_BlockingReport @pathout = @path OUTPUT

-- Step 2:
-- Setup new trace
EXEC [DBLog].[usp_setup_blockProcess_report]  @status

-- Step 3:
-- removed closed trace
exec dblog.usp_del_blockingReport_Trace @path 
end

else if (@version < 10)
begin
	print 'Version below 2008 not supported'
END
GO