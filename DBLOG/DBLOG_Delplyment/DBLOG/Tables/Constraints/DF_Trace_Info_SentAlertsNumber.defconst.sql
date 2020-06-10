ALTER TABLE [DBLog].[Trace_Info]
    ADD CONSTRAINT [DF_Trace_Info_SentAlertsNumber] DEFAULT ((0)) FOR [SentAlertsNumber];

