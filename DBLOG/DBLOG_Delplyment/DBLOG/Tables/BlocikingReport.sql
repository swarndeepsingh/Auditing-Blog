SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DBLog].[BlockingReport](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[tracestarttime] [datetime] NULL,
	[traceendtime] [datetime] NULL,
	[tracetime] [varchar](256) NULL,
	[blockingtransactions] [varchar](50) NULL,
	[reportxml] [xml] NULL,
	[status] [int] NULL
)