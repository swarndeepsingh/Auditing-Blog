create master key ENCRYPTION by password = 'N0tBl4nk'
GO

create certificate DBLOG_CERTIFICATE
encryption By Password = 'N0tBl4nk'
with subject = 'DBLOG_CERTIFICATE'
GO

create symmetric key DBLOG_KEY_01
WITH ALGORITHM = AES_256
encryption by certificate DBLOG_CERTIFICATE