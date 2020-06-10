ALTER TABLE [DBLog].[Trace_Failed_Login_Archive]
    ADD CONSTRAINT [FK_Trace_Failed_Login_Archive_Trace_Info] FOREIGN KEY ([RowID]) REFERENCES [DBLog].[Trace_Info] ([ROWID]) ON DELETE NO ACTION ON UPDATE NO ACTION;

