ALTER TABLE [DBLog].[Error_Alert]
    ADD CONSTRAINT [FK_Error_Alert_Alert_Definitions] FOREIGN KEY ([Alert_Name]) REFERENCES [DBLog].[Alert_Definitions] ([AlertName]) ON DELETE NO ACTION ON UPDATE NO ACTION;

