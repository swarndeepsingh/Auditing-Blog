ALTER TABLE [DBLog].[Trace_Exceptions]
    ADD CONSTRAINT [FK_Trace_Exceptions_Trace_Jobs] FOREIGN KEY ([TraceName]) REFERENCES [DBLog].[Trace_Jobs] ([Tracename]) ON DELETE NO ACTION ON UPDATE NO ACTION;

