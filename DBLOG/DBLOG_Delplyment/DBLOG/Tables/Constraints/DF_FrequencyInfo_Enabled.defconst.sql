ALTER TABLE [DBLog].[FrequencyInfo]
    ADD CONSTRAINT [DF_FrequencyInfo_Enabled] DEFAULT ((1)) FOR [Enabled];

