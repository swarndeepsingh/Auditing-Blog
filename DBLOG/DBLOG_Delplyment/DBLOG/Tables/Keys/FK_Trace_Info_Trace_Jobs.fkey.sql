ALTER TABLE [DBLog].[Trace_Info]
    ADD CONSTRAINT [FK_Trace_Info_Trace_Jobs] FOREIGN KEY ([Tracename]) REFERENCES [DBLog].[Trace_Jobs] ([Tracename]) ON DELETE NO ACTION ON UPDATE NO ACTION;

