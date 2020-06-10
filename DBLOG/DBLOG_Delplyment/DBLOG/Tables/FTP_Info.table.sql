CREATE TABLE [DBLog].[FTP_Info] (
    [FTP_ID]        INT           IDENTITY (1, 1) NOT NULL,
    [FTP_Name]      VARCHAR (255) NULL,
    [FTP_Server]    VARCHAR (128) NULL,
    [FTP_User_Name] VARCHAR (128) NULL,
    [FTP_Path]      VARCHAR (500) NULL,
    [work_folder]   VARCHAR (128) NULL
);

