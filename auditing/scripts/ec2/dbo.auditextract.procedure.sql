
-- usage exec auditextract 'C:\auditdata\'
use awsec2auditing
GO
if exists(select 1 from sys.objects where name ='auditextract')
begin
	drop procedure auditextract
end 
go
	create proc dbo.auditextract @path varchar(500)
	as
	declare @begindate datetime
	, @enddate datetime2(7)
	, @rows bigint
	, @fullpath varchar(500)
	, @lastpulldate datetime2(7)

	set @fullpath = @path + '\*.sqlaudit'

	select @lastpulldate = isnull(max(eventend),getdate()-180) from dbo.audittracker

	declare  @auditdata table(
		[event_time] [datetime2](7) NOT NULL,
		[sequence_number] [int] NOT NULL,
		[action_id] [varchar](4) NULL,
		[succeeded] [bit] NOT NULL,
		[permission_bitmask] [varbinary](16) NOT NULL,
		[is_column_permission] [bit] NOT NULL,
		[session_id] [smallint] NOT NULL,
		[server_principal_id] [int] NOT NULL,
		[database_principal_id] [int] NOT NULL,
		[target_server_principal_id] [int] NOT NULL,
		[target_database_principal_id] [int] NOT NULL,
		[object_id] [int] NOT NULL,
		[class_type] [varchar](2) NULL,
		[session_server_principal_name] [nvarchar](128) NULL,
		[server_principal_name] [nvarchar](128) NULL,
		[server_principal_sid] [varbinary](85) NULL,
		[database_principal_name] [nvarchar](128) NULL,
		[target_server_principal_name] [nvarchar](128) NULL,
		[target_server_principal_sid] [varbinary](85) NULL,
		[target_database_principal_name] [nvarchar](128) NULL,
		[server_instance_name] [nvarchar](128) NULL,
		[database_name] [nvarchar](128) NULL,
		[schema_name] [nvarchar](128) NULL,
		[object_name] [nvarchar](128) NULL,
		[statement] [nvarchar](4000) NULL,
		[additional_information] [nvarchar](4000) NULL,
		[file_name] [nvarchar](260) NOT NULL,
		[audit_file_offset] [bigint] NOT NULL,
		[user_defined_event_id] [smallint] NOT NULL,
		[user_defined_information] [nvarchar](4000) NULL,
		[audit_schema_version] [int] NOT NULL,
		[sequence_group_id] [varbinary](85) NULL,
		[transaction_id] [bigint] NOT NULL,
		[client_ip] [nvarchar](128) NULL,
		[application_name] [nvarchar](128) NULL,
		[duration_milliseconds] [bigint] NOT NULL,
		[response_rows] [bigint] NOT NULL,
		[affected_rows] [bigint] NOT NULL,
		[connection_id] [uniqueidentifier] NULL,
		[data_sensitivity_information] [nvarchar](4000) NULL,
		[host_name] [nvarchar](128) NULL
	) 

	insert into @auditdata
	SELECT top 500	[event_time] ,
		[sequence_number] ,
		[action_id] ,
		[succeeded] ,
		[permission_bitmask],
		[is_column_permission] ,
		[session_id] ,
		[server_principal_id] ,
		[database_principal_id] ,
		[target_server_principal_id],
		[target_database_principal_id] ,
		[object_id],
		[class_type] ,
		[session_server_principal_name] ,
		[server_principal_name] ,
		[server_principal_sid],
		[database_principal_name],
		[target_server_principal_name],
		[target_server_principal_sid] ,
		[target_database_principal_name],
		[server_instance_name] ,
		[database_name],
		[schema_name] ,
		[object_name] ,
		replace([statement], CHAR(13)+CHAR(10),' ') [statement] ,
		[additional_information] ,
		[file_name] ,
		[audit_file_offset] ,
		[user_defined_event_id],
		[user_defined_information],
		[audit_schema_version],
		[sequence_group_id]L,
		[transaction_id],
		[client_ip] ,
		[application_name] ,
		[duration_milliseconds],
		[response_rows],
		[affected_rows],
		[connection_id],
		[data_sensitivity_information],
		[host_name]
		from 
	sys.fn_get_audit_file(@fullpath, DEFAULT, DEFAULT) where event_time > @lastpulldate order by event_time

	select @rows = @@ROWCOUNT
	select @begindate=min(event_time),@enddate=max(event_time)  from @auditdata
	if(@rows>0)
	begin
	insert into audittracker
	select  @begindate, @enddate, @rows, getdate()
	end
	select * from @auditdata

go