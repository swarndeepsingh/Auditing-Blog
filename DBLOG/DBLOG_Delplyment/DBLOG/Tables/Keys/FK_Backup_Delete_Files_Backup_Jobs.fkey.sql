ALTER TABLE [DBLog].[Backup_Delete_Files]
    ADD CONSTRAINT [FK_Backup_Delete_Files_Backup_Jobs] FOREIGN KEY ([Backup_job_ID]) 
	REFERENCES [DBLog].[Backup_Jobs] ([Backup_Job_ID]) ON DELETE NO ACTION ON UPDATE NO ACTION;
