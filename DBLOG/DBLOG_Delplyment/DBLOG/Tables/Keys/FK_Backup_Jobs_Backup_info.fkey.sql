ALTER TABLE [DBLog].[Backup_Jobs]
    ADD CONSTRAINT [FK_Backup_Jobs_Backup_info] FOREIGN KEY ([Backup_ID]) REFERENCES [DBLog].[Backup_info] ([Backup_ID]) ON DELETE NO ACTION ON UPDATE NO ACTION;

