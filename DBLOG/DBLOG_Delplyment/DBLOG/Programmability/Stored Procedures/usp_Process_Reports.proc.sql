-- [dblog].[usp_Process_Reports]
CREATE proc [DBLog].[usp_Process_Reports]
as
declare @SPName varchar(200), @Parameter varchar(100), @propValue varchar(255)
, @addValue varchar(8000), @moreValue varchar(500), @reportName varchar(500)
,@sql nvarchar(4000), @sqlvalue varchar(100), @emailProfileID int
, @report_SP varchar(4000), @lastrun datetime, @reportgap varchar(10)
declare cursor_Report Cursor
for select distinct ReportName from dblog.report_properties where PropertyName = 'Enabled' 
and PropertyValue = '1'

open cursor_Report
fetch next from cursor_Report into @reportName

while @@FETCH_STATUS = 0
begin

	select @lastrun = cast(propertyvalue as datetime) from dblog.report_properties where reportname = @reportName and propertyname = 'Last_Run'
	
	select @reportgap = propertyvalue from dblog.report_properties where reportname = @reportName and propertyname = 'Report_Min_Gap_Hours' 	

	if DATEDIFF(hour,@lastrun,getdate()) < @reportgap
		goto quit
			
	select @emailProfileID = propertyvalue from DBLog.Report_Properties with (NOLOCK)
	where reportname = @reportName and propertyname ='emailprofileid'
	
	select @report_SP = PropertyValue from DBLog.Report_Properties with (NOLOCK)
	where reportname = @reportName and propertyname = 'SP_Name'

	declare cursor_parameter cursor
	for select propertyvalue from dblog.report_properties  where propertyname ='Parameter'
	and reportname = @reportName
	
	open cursor_parameter
	fetch next from cursor_parameter
	into @parameter
	
	while @@FETCH_STATUS = 0
	begin
		
		
		
		select @sql=  additionalvalue  from dblog.report_properties  where propertyname ='Parameter'
	and reportname = @reportName and propertyvalue = @Parameter
		
		EXEC sp_executesql @sql, N'@param varchar(100) OUTPUT', @sqlvalue OUTPUT


		set @report_SP = @report_SP + ' ''' + @sqlvalue + ''', '
		
		
		set @sqlvalue = @sqlvalue
		update dblog.report_properties
		set morevalue = @sqlvalue
		where propertyname ='Parameter'
		and reportname = @reportName and propertyvalue = @Parameter 
		

		
			fetch next from cursor_parameter
			into @parameter
	end
	close cursor_parameter
	deallocate cursor_parameter
	
	update dblog.report_properties
	set PropertyValue = GETDATE()
	where propertyname ='Last_Run'
	and reportname = @reportName 
	
	set @report_sp= @report_sp + ' ' + cast(@emailProfileID as varchar(10))
	exec (@report_sp)
	
	
	fetch next from cursor_Report into @reportName
end
quit:
close cursor_Report
deallocate cursor_Report


