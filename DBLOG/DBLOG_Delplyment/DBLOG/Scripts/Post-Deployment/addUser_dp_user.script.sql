
if not exists (select * from sys.server_principals where name = 'dp_user')
CREATE LOGIN [dp_user] WITH PASSWORD=N'xxxx', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF

if not exists (select 1 from sys.database_principals where name = 'dp_user')
CREATE USER [dp_user] FOR LOGIN [dp_user] WITH DEFAULT_SCHEMA=[dbo]


				
EXEC sp_addrolemember N'db_datareader', [dp_user]
EXEC sp_addrolemember N'db_datawriter', [dp_user]
EXEC sp_addrolemember N'db_ddladmin', [dp_user]