USE [awsec2auditing]
GO


create table audittracker
(
auditbatchid int identity(1,1) primary key,
eventbegin datetime2(7),
eventend datetime2(7),
numberofrows bigint,
processedtime datetime
)
go

alter table audittracker
alter column eventbegin datetime2(7)
alter table audittracker
alter column eventend datetime2(7)