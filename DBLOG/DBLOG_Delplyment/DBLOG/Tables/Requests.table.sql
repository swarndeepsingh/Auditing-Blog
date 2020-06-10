use DBLOG
GO
CREATE TABLE [DBLog].[requests](
	[CaptureDataID] [bigint] IDENTITY(1,1) NOT NULL,
	[session_id] [smallint] NOT NULL,
	[request_id] [int] NULL,
	[command] [nvarchar](32) NOT NULL,
	[start_time] [datetime] NOT NULL,
	[status] [nvarchar](30) NOT NULL,
	[sql_handle] [varbinary](64) NULL,
	[plan_handle] [varbinary](64) NULL,
	[object_id] [int] NULL,
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
	[logical_reads] [bigint] NULL,
	[ClientIP] [varchar](15) NULL,
	[MemoryMB] [numeric](18, 2) NULL,
	[TempDBMB] [numeric](18, 2) NULL,
	[Statement_StartOffSet] [int] NULL,
	[Statement_EndOffSet] [int] NULL,
	[ServerName] [nvarchar](128) NULL,
	[collectiondate] [datetime] NOT NULL,
	[ExportStatus] [int] NOT NULL CONSTRAINT [DF_requests_ExportStatus]  DEFAULT ((0)),
 CONSTRAINT [PK_requests] PRIMARY KEY CLUSTERED 
(
	[CaptureDataID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO