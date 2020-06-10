
CREATE TABLE [DBLog].[Current_Job_Status_report](
	[Job_num] [int] IDENTITY(1,1) NOT NULL,
	[Job_id] [varchar](100) NULL,
	[originating_server] [varchar](100) NULL,
	[job_name] [varchar](2000) NULL,
	[job_enabled] [int] NULL,
	[job_description] [varchar](4000) NULL,
	[last_run_date] [varchar](100) NULL,
	[last_run_time] [varchar](100) NULL,
	[last_run_outcome] [int] NULL,
	[has_step] [int] NULL,
	[has_schedule] [int] NULL
 )