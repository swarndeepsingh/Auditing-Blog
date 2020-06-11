CREATE DATABASE [destination_migration]
GO
USE destination_migration
GO
CREATE TABLE [dbo].[headerdetails](
	[id] [bigint] NOT NULL,
	[backupfilepath] varchar(1024),
	[sourceservername] [varchar](100) NOT NULL,
	[sourcedatabasename] [varchar](100) NOT NULL,
	[backupname] [varchar](1024) NOT NULL,
	[compressed] [bit] NOT NULL,
	[backupsize] [bigint] NOT NULL,
	[compressedbackupsize] [bigint] NOT NULL,
	[firstlsn] [bigint] NOT NULL,
	[lastlsn] [bigint] NOT NULL,
	[checkpointlsn] [bigint] NOT NULL,
	[databasebackuplsn] [bigint] NOT NULL,
	[compatibilitylevel] [int] NOT NULL,
	[machinename] [varchar](100) NOT NULL,
	[beginslogchain] [bit] NOT NULL,
	[differentialbaselsn] [bigint] NULL,
	[destinationdatabasename] [varchar](100) NOT NULL,
	[datecreated] [datetime] NOT NULL,
	[modifydate] [datetime] NOT NULL
) ON [PRIMARY]

GO