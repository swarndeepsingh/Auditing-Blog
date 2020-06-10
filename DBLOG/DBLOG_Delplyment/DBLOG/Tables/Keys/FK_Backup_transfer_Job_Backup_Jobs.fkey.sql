ALTER TABLE [DBLog].[Backup_transfer_Job]
    ADD CONSTRAINT [FK_Backup_transfer_Job_Backup_Jobs] FOREIGN KEY ([Backup_Job_ID]) REFERENCES [DBLog].[Backup_Jobs] ([Backup_Job_ID]) ON DELETE NO ACTION ON UPDATE NO ACTION;

