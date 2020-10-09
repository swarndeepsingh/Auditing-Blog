if exists(SELECT type_desc, type
        FROM sys.procedures WITH(NOLOCK)
        WHERE NAME = 'auditextract_json'
            AND type = 'P')
	DROP PROCEDURE dbo.[auditextract_json]
GO

create proc [dbo].[auditextract_json] @path varchar(500)
	as
	begin
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
		[session_id] [smallint] NOT NULL,
		[server_principal_id] [int] NOT NULL,
		[database_principal_id] [int] NOT NULL,
		[target_server_principal_id] [int] NOT NULL,
		[target_database_principal_id] [int] NOT NULL,
		[object_id] [int] NOT NULL,
		[class_type] [varchar](2) NULL,
		[server_principal_name] [nvarchar](128) NULL,
		[database_principal_name] [nvarchar](128) NULL,
		[server_instance_name] [nvarchar](128) NULL,
		[database_name] [nvarchar](128) NULL,
		[schema_name] [nvarchar](128) NULL,
		[object_name] [nvarchar](128) NULL,
		[statement] [nvarchar](4000) NULL,
		[file_name] [nvarchar](260) NOT NULL,
		[transaction_id] [bigint] NOT NULL,
		[client_ip] [nvarchar](128) NULL,
		[application_name] [nvarchar](128) NULL,
		[duration_milliseconds] [bigint] NOT NULL,
		[response_rows] [bigint] NOT NULL,
		[affected_rows] [bigint] NOT NULL
	) 

	insert into @auditdata
	SELECT top 500	[event_time] ,
		[sequence_number] ,
		[action_id] ,
		[succeeded] ,
		[session_id] ,
		[server_principal_id] ,
		[database_principal_id] ,
		[target_server_principal_id],
		[target_database_principal_id] ,
		[object_id],
		[class_type] ,
		[server_principal_name] ,
		[database_principal_name],
		[server_instance_name] ,
		[database_name],
		[schema_name] ,
		[object_name] ,
		replace([statement], CHAR(13)+CHAR(10),' ') [statement] ,
		[file_name] ,
		[transaction_id],
		[client_ip] ,
		[application_name] ,
		[duration_milliseconds],
		[response_rows],
		[affected_rows]
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
 
 end
 go
