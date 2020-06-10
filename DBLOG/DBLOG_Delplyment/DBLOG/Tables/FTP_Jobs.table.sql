CREATE TABLE [DBLog].[FTP_Jobs] (
    [FTP_Job_ID] INT            IDENTITY (1, 1) NOT NULL,
    [FTP_ID]     INT            NULL,
    [BCP_Id]     INT            NULL,
    [ftp_status] VARCHAR (10)   NULL,
    [startTime]  DATETIME       NULL,
    [endTime]    DATETIME       NULL,
    [comments]   VARCHAR (2000) NULL
);

