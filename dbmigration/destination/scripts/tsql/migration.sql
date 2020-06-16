CREATE DATABASE [destination_migration]
GO
USE destination_migration
GO
CREATE TABLE [dbo].[headerdetails](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[backupfilepath] [varchar](2048) NULL,
	[filename] [varchar](500) NOT NULL,
	[sourceservername] [varchar](100) NOT NULL,
	[sourcedatabasename] [varchar](100) NOT NULL,
	[backuptype] [int] NULL,
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
	[beginslogchain] [varchar](20) NOT NULL,
	[differentialbaselsn] [bigint] NULL,
	[destinationdatabasename] [varchar](100) NOT NULL,
	[datecreated] [datetime] NOT NULL,
	[modifydate] [datetime] NULL,
 CONSTRAINT [PK_headerdetails] PRIMARY KEY CLUSTERED 
(
	[filename] ASC,
	[sourceservername] ASC,
	[sourcedatabasename] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO