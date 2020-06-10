ALTER TABLE [DBLog].[Alert_Definitions]
    ADD CONSTRAINT [DF_Alert_Definitions_EmailProfileID] DEFAULT ((1)) FOR [EmailProfileID];

