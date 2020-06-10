ALTER TABLE [DBLog].[Backup_info]
    ADD CONSTRAINT [DF_Backup_info_DR_Transfer] DEFAULT ((0)) FOR [DR_Transfer];

