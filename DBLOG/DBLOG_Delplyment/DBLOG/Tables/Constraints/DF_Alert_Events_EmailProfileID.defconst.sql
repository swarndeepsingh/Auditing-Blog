ALTER TABLE [DBLog].[Alert_Events]
    ADD CONSTRAINT [DF_Alert_Events_EmailProfileID] DEFAULT ((1)) FOR [EmailProfileID];

