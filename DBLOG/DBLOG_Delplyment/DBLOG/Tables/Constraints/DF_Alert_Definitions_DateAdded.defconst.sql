ALTER TABLE [DBLog].[Alert_Definitions]
    ADD CONSTRAINT [DF_Alert_Definitions_DateAdded] DEFAULT (getdate()) FOR [DateAdded];

