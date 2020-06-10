ALTER TABLE [DBLog].[Trace_Jobs]
    ADD CONSTRAINT [DF_Trace_Jobs_CreateDate] DEFAULT (getdate()) FOR [CreateDate];

