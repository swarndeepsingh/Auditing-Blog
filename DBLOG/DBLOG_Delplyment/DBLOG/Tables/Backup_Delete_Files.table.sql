CREATE TABLE [DBLog].[Backup_Delete_Files] (
    [Delete_ID]      INT            IDENTITY (1, 1) NOT NULL,
    [Backup_ID]      INT            NOT NULL,
    [Backup_Job_ID]  INT            NOT NULL,
    [LocationID]     INT            NULL,
    [File_Location]  VARCHAR (8000)  NULL,
    [Location_Type]  VARCHAR (8000) NOT NULL,
    [Status]         VARCHAR (50)   NOT NULL,
    [Start_Time]     DATETIME       NULL,
    [end_time]       DATETIME       NULL,
    [date_scheduled] DATETIME       NOT NULL,
    [Message]        VARCHAR (8000) NULL
);





