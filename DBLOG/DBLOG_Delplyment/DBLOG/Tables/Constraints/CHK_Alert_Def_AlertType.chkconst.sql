ALTER TABLE [DBLog].[Alert_Definitions]
    ADD CONSTRAINT [CHK_Alert_Def_AlertType] CHECK ([AlertType]='Warning' OR [AlertType]='Report' OR [AlertType]='Information' OR [AlertType]='Error' OR [AlertType]='Alert');

