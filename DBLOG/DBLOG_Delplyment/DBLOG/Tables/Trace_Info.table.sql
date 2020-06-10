CREATE TABLE [DBLog].[Trace_Info] (
    [ROWID]            INT            IDENTITY (1, 1) NOT NULL,
    [Tracename]        VARCHAR (255)  NULL,
    [TraceID]          INT            NULL,
    [TraceFile]        NVARCHAR (255) NULL,
    [ServerName]       NVARCHAR (255) NULL,
    [CreateDate]       DATETIME       NULL,
    [Active]           INT            NULL,
    [Archived]         INT            NULL,
    [FileDeleted]      INT            NULL,
    [RowsImported]     INT            NULL,
    [SentAlertsNumber] INT            NULL
);

