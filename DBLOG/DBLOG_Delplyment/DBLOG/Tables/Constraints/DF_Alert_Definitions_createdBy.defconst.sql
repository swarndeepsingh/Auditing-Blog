ALTER TABLE [DBLog].[Alert_Definitions]
    ADD CONSTRAINT [DF_Alert_Definitions_createdBy] DEFAULT (suser_sname()) FOR [createdBy];

