ALTER TABLE [DBLog].[Backup_info]
    ADD CONSTRAINT [chk_CheckBackupLocationMirrorSlash] CHECK (substring([MirrorLocation],len([MirrorLocation]),len([MirrorLocation]))<>'\');

