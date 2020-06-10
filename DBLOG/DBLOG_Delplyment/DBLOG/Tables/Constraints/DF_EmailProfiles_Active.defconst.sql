ALTER TABLE [DBLog].[EmailProfiles]
    ADD CONSTRAINT [DF_EmailProfiles_Active] DEFAULT ((1)) FOR [Active];

