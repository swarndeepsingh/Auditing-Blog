
CREATE TABLE DBLOG.CaptureData (
ID bigint identity PRIMARY KEY,
StartTime datetime,
EndTime datetime,
ServerName varchar(500),
PullPeriod int
)