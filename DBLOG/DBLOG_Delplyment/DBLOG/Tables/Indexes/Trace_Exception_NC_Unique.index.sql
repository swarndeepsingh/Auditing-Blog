﻿CREATE UNIQUE NONCLUSTERED INDEX [Trace_Exception_NC_Unique]
    ON [DBLog].[Trace_Exceptions]([TraceName] ASC, [ColumnNumber] ASC, [ColumnValue] ASC) WITH (FILLFACTOR = 80, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF, ONLINE = OFF, MAXDOP = 0)
    ON [PRIMARY];





