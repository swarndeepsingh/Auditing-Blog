USE [master]
GO
/****** Object:  Database [DBLOGDR]    Script Date: 06/02/2017 17:30:47 ******/
CREATE DATABASE [DBLOGDR] ON  PRIMARY 
( NAME = N'DBLOGDR', FILENAME = N'U:\Database\DataFiles\DBLOGDR.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'DBLOGDR_log', FILENAME = N'W:\Database\LogFiles\DBLOGDR_log.ldf' , SIZE = 1280KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [DBLOGDR] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DBLOGDR].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [DBLOGDR] SET ANSI_NULL_DEFAULT OFF
GO
ALTER DATABASE [DBLOGDR] SET ANSI_NULLS OFF
GO
ALTER DATABASE [DBLOGDR] SET ANSI_PADDING OFF
GO
ALTER DATABASE [DBLOGDR] SET ANSI_WARNINGS OFF
GO
ALTER DATABASE [DBLOGDR] SET ARITHABORT OFF
GO
ALTER DATABASE [DBLOGDR] SET AUTO_CLOSE OFF
GO
ALTER DATABASE [DBLOGDR] SET AUTO_CREATE_STATISTICS ON
GO
ALTER DATABASE [DBLOGDR] SET AUTO_SHRINK OFF
GO
ALTER DATABASE [DBLOGDR] SET AUTO_UPDATE_STATISTICS ON
GO
ALTER DATABASE [DBLOGDR] SET CURSOR_CLOSE_ON_COMMIT OFF
GO
ALTER DATABASE [DBLOGDR] SET CURSOR_DEFAULT  GLOBAL
GO
ALTER DATABASE [DBLOGDR] SET CONCAT_NULL_YIELDS_NULL OFF
GO
ALTER DATABASE [DBLOGDR] SET NUMERIC_ROUNDABORT OFF
GO
ALTER DATABASE [DBLOGDR] SET QUOTED_IDENTIFIER OFF
GO
ALTER DATABASE [DBLOGDR] SET RECURSIVE_TRIGGERS OFF
GO
ALTER DATABASE [DBLOGDR] SET  DISABLE_BROKER
GO
ALTER DATABASE [DBLOGDR] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO
ALTER DATABASE [DBLOGDR] SET DATE_CORRELATION_OPTIMIZATION OFF
GO
ALTER DATABASE [DBLOGDR] SET TRUSTWORTHY OFF
GO
ALTER DATABASE [DBLOGDR] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO
ALTER DATABASE [DBLOGDR] SET PARAMETERIZATION SIMPLE
GO
ALTER DATABASE [DBLOGDR] SET READ_COMMITTED_SNAPSHOT OFF
GO
ALTER DATABASE [DBLOGDR] SET HONOR_BROKER_PRIORITY OFF
GO
ALTER DATABASE [DBLOGDR] SET  READ_WRITE
GO
ALTER DATABASE [DBLOGDR] SET RECOVERY SIMPLE
GO
ALTER DATABASE [DBLOGDR] SET  MULTI_USER
GO
ALTER DATABASE [DBLOGDR] SET PAGE_VERIFY CHECKSUM
GO
ALTER DATABASE [DBLOGDR] SET DB_CHAINING OFF
GO
EXEC sys.sp_db_vardecimal_storage_format N'DBLOGDR', N'ON'
GO
USE [DBLOGDR]
GO
/****** Object:  Table [dbo].[backupheaders_bkup]    Script Date: 06/02/2017 17:30:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[backupheaders_bkup](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[FileName] [varchar](1024) NOT NULL,
	[DBName] [varchar](500) NOT NULL,
	[SQLServerName] [varchar](1024) NOT NULL,
	[FirstLSN] [numeric](38, 0) NOT NULL,
	[LastLSN] [numeric](38, 0) NOT NULL,
	[CheckPointLSN] [numeric](38, 0) NOT NULL,
	[DatabaseBackupLSN] [numeric](38, 0) NOT NULL,
	[NativeBackupSize] [varchar](20) NOT NULL,
	[DBSize] [varchar](20) NOT NULL,
	[BackupStart] [datetime] NULL,
	[BackupEnd] [datetime] NULL,
	[restorestart] [datetime] NULL,
	[restoreend] [datetime] NULL,
	[BackupType] [varchar](100) NOT NULL,
	[Tool] [varchar](50) NOT NULL,
	[Insertdate] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BackupHeaders]    Script Date: 06/02/2017 17:30:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BackupHeaders](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[FileName] [varchar](1024) NOT NULL,
	[FolderName] [varchar](1024) NOT NULL,
	[DBName] [varchar](500) NOT NULL,
	[SQLServerName] [varchar](1024) NOT NULL,
	[FirstLSN] [numeric](38, 0) NOT NULL,
	[LastLSN] [numeric](38, 0) NOT NULL,
	[CheckPointLSN] [numeric](38, 0) NOT NULL,
	[DatabaseBackupLSN] [numeric](38, 0) NOT NULL,
	[NativeBackupSize] [varchar](20) NOT NULL,
	[DBSize] [varchar](20) NULL,
	[BackupStart] [datetime] NULL,
	[BackupEnd] [datetime] NULL,
	[restorestart] [datetime] NULL,
	[restoreend] [datetime] NULL,
	[BackupType] [varchar](100) NOT NULL,
	[Tool] [varchar](50) NOT NULL,
	[Insertdate] [datetime] NULL,
	[backuptypecomp]  AS (case substring([backuptype],(1),(1)) when '1' then 'Full' when '2' then 'TLOG' when (4) then 'File' when (5) then 'Diff' when (7) then 'Partial' when (8) then 'Partial Diff'  end),
	[restoreprogress] [varchar](50) NULL,
	[lastupdated] [datetime] NULL,
 CONSTRAINT [PK_BackupHeaders] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_UNQ_BackupHeaders_Filename] ON [dbo].[BackupHeaders] 
(
	[FileName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Default [DF_BackupHeaders_Insertdate]    Script Date: 06/02/2017 17:30:48 ******/
ALTER TABLE [dbo].[BackupHeaders] ADD  CONSTRAINT [DF_BackupHeaders_Insertdate]  DEFAULT (getdate()) FOR [Insertdate]
GO
