ALTER TABLE [DBLog].[Backup_transfer_Job]
    ADD CONSTRAINT [FK_Backup_transfer_Job_Backup_info] FOREIGN KEY ([Backup_ID]) REFERENCES [DBLog].[Backup_info] ([Backup_ID]) ON DELETE NO ACTION ON UPDATE NO ACTION;

