USE [awsec2auditing]
GO

if not exists (select 1 from sys.objects where name ='audittracker')
begin
create table audittracker
(
auditbatchid int identity(1,1) primary key,
eventbegin datetime2(7),
eventend datetime2(7),
numberofrows bigint,
processedtime datetime
)

end
go