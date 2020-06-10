CREATE TABLE [DBLog].[Trace_Failed_Login_Archive] (
    [RowID]      INT            NULL,
    [TEXTDATA]   VARCHAR (8000) NULL,
    [HostName]   NVARCHAR (256) NULL,
    [SPID]       NVARCHAR (10)  NULL,
    [StartTime]  DATETIME       NULL,
    [Success]    INT            NULL,
    [ServerName] NVARCHAR (256) NULL,
    [DBName]     NVARCHAR (256) NULL,
    [NTUserName] NVARCHAR (256) NULL,
    [LoginName]  NVARCHAR (256) NULL
);

