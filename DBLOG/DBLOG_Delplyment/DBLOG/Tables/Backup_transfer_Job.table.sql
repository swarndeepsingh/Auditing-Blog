CREATE TABLE [DBLog].[Backup_transfer_Job] (
    [Transfer_ID]           INT            IDENTITY (1, 1) NOT NULL,
    [Backup_Job_ID]         INT            NOT NULL,
    [Backup_ID]             INT            NOT NULL,
    [SourceLocationID]      INT            NULL,
    [Source]                VARCHAR (8000) NOT NULL,
    [DestinationLocationID] INT            NULL,
    [Destination]           VARCHAR (8000) NOT NULL,
    [Status]                VARCHAR (20)   NOT NULL,
    [startdate]             DATETIME       NULL,
    [enddate]               DATETIME       NULL,
    [Message]               VARCHAR (8000) NULL
);





