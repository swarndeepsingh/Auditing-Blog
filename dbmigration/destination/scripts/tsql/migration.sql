CREATE DATABASE [destination_migration]
GO
USE destination_migration
GO
CREATE TABLE [dbo].[headerdetails](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[backupfilepath] varchar(1024),
	[sourceservername] [varchar](100) NOT NULL,
	[sourcedatabasename] [varchar](100) NOT NULL,
	[backupname] [varchar](1024) NOT NULL,
    backuptype int,
	[compressed] [bit] NOT NULL,
	[backupsize] [bigint] NOT NULL,
	[compressedbackupsize] [bigint] NOT NULL,
	[firstlsn] [bigint] NOT NULL,
	[lastlsn] [bigint] NOT NULL,
	[checkpointlsn] [bigint] NOT NULL,
	[databasebackuplsn] [bigint] NOT NULL,
	[compatibilitylevel] [int] NOT NULL,
	[machinename] [varchar](100) NOT NULL,
	[beginslogchain] varchar(20) NOT NULL,
	[differentialbaselsn] [bigint] NULL,
	[destinationdatabasename] [varchar](100) NOT NULL,
	[datecreated] [datetime] NOT NULL,
	[modifydate] [datetime]  NULL
) ON [PRIMARY]

GO