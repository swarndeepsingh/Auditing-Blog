ALTER TABLE [DBLog].[Backup_Delete_Files]
    ADD CONSTRAINT [FK_Backup_Delete_Files_Location_Details] FOREIGN KEY ([LocationID]) REFERENCES [DBLog].[Location_Details] ([LocationID]) ON DELETE NO ACTION ON UPDATE NO ACTION;

