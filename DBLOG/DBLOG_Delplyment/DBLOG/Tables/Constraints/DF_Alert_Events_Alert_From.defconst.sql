ALTER TABLE [DBLog].[Alert_Events]
    ADD CONSTRAINT [DF_Alert_Events_Alert_From] DEFAULT (('DBALERT_DBA.'+@@servername)+'@ebix.com') FOR [Alert_From];

