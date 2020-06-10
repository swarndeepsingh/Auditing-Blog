ALTER TABLE [DBLog].[Alert_Definitions]
    ADD CONSTRAINT [DF_Alert_Definitions_AlertFrom] DEFAULT (('DBALERT_DBA.'+@@servername)+'@ebix.com') FOR [AlertFrom];

