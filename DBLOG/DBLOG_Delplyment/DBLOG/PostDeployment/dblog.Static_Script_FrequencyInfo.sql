update dblog.Backup_info
		set frequencyName =
	    case  when BackupType='D' then 'Weekly_1'  when BackupType='I' then 'Daily_1' when BackupType='L' then 'Minute_1' end
		where frequencyName is null




-- FrequencyInfo

declare @freqInfo table(
	[frequencyName] [varchar](50) NOT NULL,
	[Frequency] [varchar](100) NOT NULL,
	[FrequencyNumber] [int] NOT NULL,
	[Description] [varchar](500) NULL,
	[Enabled] [bit] NOT NULL)

insert  @freqInfo
VALUES
 (N'10_Minutes', N'Hour', 6, N'Every 10 Minutes', 1),
 (N'Daily_1', N'Day', 1, N'Every Day', 1),
 (N'Hourly_1', N'Hour', 1, N'Every Hour', 1),
 (N'Monthly_1', N'Month', 1, N'Every Month', 1),
 (N'Monthly_2', N'Month', 2, N'Twice a Month', 1),
 (N'Weekly_1', N'Week', 1, N'Once a Week', 1)


MERGE DBLog.FrequencyInfo 
USING (SELECT [frequencyName], [Frequency], [FrequencyNumber], [Description], [Enabled] FROM @freqInfo) 
AS updatedData
([frequencyName], [Frequency], [FrequencyNumber], [Description], [Enabled])
ON (DBLog.frequencyInfo.FrequencyName = updatedData.FrequencyName)
WHEN NOT MATCHED THEN
INSERT([frequencyName], [Frequency], [FrequencyNumber], [Description], [Enabled])
VALUES(updateddata.[frequencyName], updateddata.[Frequency], updateddata.[FrequencyNumber]
, updateddata.[Description], updateddata.[Enabled])
WHEN MATCHED THEN
UPDATE
SET [Frequency] = updatedData.[Frequency]
,[FrequencyNumber] = updatedData.[FrequencyNumber]
,[Description] = updatedData.[Description]
,[Enabled] = updatedData.[Enabled];