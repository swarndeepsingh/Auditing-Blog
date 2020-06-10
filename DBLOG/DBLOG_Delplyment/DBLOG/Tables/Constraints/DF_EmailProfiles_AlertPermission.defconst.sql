ALTER TABLE [DBLog].[EmailProfiles]
    ADD CONSTRAINT [DF_EmailProfiles_AlertPermission] DEFAULT ('S') FOR [AlertPermission];

