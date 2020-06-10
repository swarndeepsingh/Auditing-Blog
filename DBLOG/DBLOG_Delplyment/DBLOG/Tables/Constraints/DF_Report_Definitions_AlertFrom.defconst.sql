ALTER TABLE [DBLog].[EmailProfiles]
    ADD CONSTRAINT [DF_Report_Definitions_AlertFrom] DEFAULT (('DBALERT_DBA.'+@@servername)+'@ebix.com') FOR [From_Email];

