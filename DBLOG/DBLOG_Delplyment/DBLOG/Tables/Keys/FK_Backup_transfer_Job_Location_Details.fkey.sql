ALTER TABLE [DBLog].[Backup_transfer_Job]
    ADD CONSTRAINT [FK_Backup_transfer_Job_Location_Details] FOREIGN KEY ([SourceLocationID]) REFERENCES [DBLog].[Location_Details] ([LocationID]) ON DELETE NO ACTION ON UPDATE NO ACTION;

