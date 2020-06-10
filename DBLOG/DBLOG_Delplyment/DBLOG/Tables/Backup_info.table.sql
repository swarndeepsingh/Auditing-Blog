CREATE TABLE [DBLog].[Backup_info] (
    [Backup_ID]                 INT            IDENTITY (1, 1) NOT NULL,
    [BackupName]                VARCHAR (1024)  NOT NULL,
    [ServerName]                VARCHAR (100)  NOT NULL,
    [DBName]                    VARCHAR (1024)  NOT NULL,
    [BackupLocationID]          INT            NULL,
    [BackupLocation]            VARCHAR (8000) NULL,
    [MirrorLocationID]          INT            NULL,
    [MirrorLocation]            VARCHAR (8000) NULL,
    [BackupType]                VARCHAR (100)  NOT NULL,
    [Enabled]                   BIT            NOT NULL,
    [DR_Transfer]               BIT            NOT NULL,
    [CompressBackup]            BIT            NULL,
    [UseInternalMirrorFunction] BIT            NULL,
    [LocalRetention_days]       INT            NULL,
    [RemoteRetention_days]      INT            NULL,
    [FrequencyName]             VARCHAR (200)  NULL,
	[BackupToolID]				VARCHAR(100) default 'SQL',
	[TransferMethod]            VARCHAR (50)  NOT NULL DEFAULT ('ROBOCOPY')
);









