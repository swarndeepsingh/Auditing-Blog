USE [ifly_dw]
GO
/****** Object:  Table [dbo].[FACT_POmeasure]    Script Date: 05/12/2016 10:02:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACT_POmeasure](
	[pomeasure_id] [bigint] IDENTITY(1,1) NOT NULL,
	[POID] [int] NULL,
	[emp_id] [int] NULL,
	[RO_Code] [int] NULL,
	[RT_Code] [varchar](10) NULL,
	[stat_code] [nchar](10) NULL,
	[cost] [float] NULL,
	[last_updated] [datetime] NULL,
	[request_year] [varchar](4) NULL,
	[Description] [varchar](1024) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DIM_Status]    Script Date: 05/12/2016 10:02:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DIM_Status](
	[STAT_code] [nchar](10) NOT NULL,
	[STATUs_Type] [varchar](50) NULL,
 CONSTRAINT [PK_DIM_Status] PRIMARY KEY CLUSTERED 
(
	[STAT_code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DIM_RO]    Script Date: 05/12/2016 10:02:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DIM_RO](
	[RO_Code] [int] NOT NULL,
	[RO_City] [varchar](50) NULL,
	[RO_Currency] [varchar](20) NULL,
 CONSTRAINT [PK_DIM_RO] PRIMARY KEY CLUSTERED 
(
	[RO_Code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DIM_RequestCategory]    Script Date: 05/12/2016 10:02:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DIM_RequestCategory](
	[RT_Code] [varchar](10) NOT NULL,
	[RT_Description] [varchar](200) NULL,
 CONSTRAINT [PK_DIM_RequestCategory] PRIMARY KEY CLUSTERED 
(
	[RT_Code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DIM_Employees]    Script Date: 05/12/2016 10:02:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DIM_Employees](
	[emp_id] [int] NOT NULL,
	[emp_firstname] [varchar](50) NULL,
	[emp_lastname] [varchar](50) NULL,
	[emp_email] [varchar](50) NULL,
	[emp_status] [varchar](10) NULL,
 CONSTRAINT [PK_DIM_Employees] PRIMARY KEY CLUSTERED 
(
	[emp_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
