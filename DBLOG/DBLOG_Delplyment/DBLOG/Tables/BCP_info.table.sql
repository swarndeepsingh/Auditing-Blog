CREATE TABLE [DBLog].[BCP_info] (
    [BCP_ID]          INT           IDENTITY (1, 1) NOT NULL,
    [BCP_Location_ID] INT           NULL,
    [BCP_Folder]      VARCHAR (255) NULL,
    [BCP_File]        VARCHAR (255) NULL,
    [Message]         VARCHAR (255) NULL
);

