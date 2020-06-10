ALTER TABLE [DBLog].[Backup_info]
    ADD CONSTRAINT [chk_CheckBackupLocationSlash] CHECK (substring([BackupLocation],len([backuplocation]),len([backuplocation]))<>'\');

