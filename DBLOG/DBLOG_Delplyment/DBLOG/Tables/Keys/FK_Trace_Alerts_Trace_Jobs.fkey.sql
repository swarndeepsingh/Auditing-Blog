ALTER TABLE [DBLog].[Trace_Alerts]
    ADD CONSTRAINT [FK_Trace_Alerts_Trace_Jobs] FOREIGN KEY ([TraceName]) REFERENCES [DBLog].[Trace_Jobs] ([Tracename]) ON DELETE NO ACTION ON UPDATE NO ACTION;

