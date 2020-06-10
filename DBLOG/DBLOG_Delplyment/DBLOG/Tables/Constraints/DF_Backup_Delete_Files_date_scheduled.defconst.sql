ALTER TABLE [DBLog].[Backup_Delete_Files]
    ADD CONSTRAINT [DF_Backup_Delete_Files_date_scheduled] DEFAULT (getdate()) FOR [date_scheduled];

