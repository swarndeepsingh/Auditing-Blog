ALTER TABLE [DBLog].[Backup_info]
    ADD CONSTRAINT [DF_Backup_info_FrequencyName] DEFAULT ('case  when [BackupType]=''D'' then FrequencyName=''Weekly_1''  when [BackupType]=''I'' then FrequencyName= =''Daily_1'' when [BackupType]=''L'' then FrequencyName=''1_Minutes'' end') FOR [FrequencyName];

