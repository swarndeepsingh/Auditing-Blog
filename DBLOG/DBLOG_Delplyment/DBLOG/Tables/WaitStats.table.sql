
CREATE TABLE DBLOG.WaitStats 
(
CaptureDataID bigint, 
WaitType varchar(200), 
wait_S decimal(20,5), 
Resource_S decimal (20,5), 
Signal_S decimal (20,5), 
WaitCount bigint, 
Avg_Wait_S numeric(10, 6), 
Avg_Resource_S numeric(10, 6),
Avg_Signal_S numeric(10, 6), 
CaptureDate datetime,
[ExportStatus] [bit] NOT NULL CONSTRAINT [DF_WaitStats_ExportStatus]  DEFAULT ((0))
)