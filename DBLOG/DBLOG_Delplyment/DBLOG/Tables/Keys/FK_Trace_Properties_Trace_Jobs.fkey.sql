ALTER TABLE [DBLog].[Trace_Properties]
    ADD CONSTRAINT [FK_Trace_Properties_Trace_Jobs] FOREIGN KEY ([TraceName]) REFERENCES [DBLog].[Trace_Jobs] ([Tracename]) ON DELETE NO ACTION ON UPDATE NO ACTION;

