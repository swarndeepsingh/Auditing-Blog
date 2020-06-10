ALTER TABLE [DBLog].[Backup_info]
    ADD CONSTRAINT [DF_Backup_info_ServerName] DEFAULT (@@servername) FOR [ServerName];

