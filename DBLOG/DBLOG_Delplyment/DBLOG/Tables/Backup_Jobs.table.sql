CREATE TABLE [DBLog].[Backup_Jobs] (
    [Backup_Job_ID]      INT            IDENTITY (1, 1) NOT NULL,
    [Backup_ID]          INT            NOT NULL,
    [Backup_Start_Time]  DATETIME       NOT NULL,
    [Backup_End_Time]    DATETIME       NULL,
    [FileName]           VARCHAR (8000) NULL,
    [FileName_Mirror]    VARCHAR (8000) NULL,
    [status]             VARCHAR (8000) NOT NULL,
    [retainUntil_local]  DATETIME       NULL,
    [retainUntil_remote] DATETIME       NULL,
	BackupSizeKB		 Numeric(20,0)
);



