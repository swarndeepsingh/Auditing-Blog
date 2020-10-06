if not exists(select 1 from sys.databases where name='awsec2auditing')
begin
    create database awsec2auditing
end
go
