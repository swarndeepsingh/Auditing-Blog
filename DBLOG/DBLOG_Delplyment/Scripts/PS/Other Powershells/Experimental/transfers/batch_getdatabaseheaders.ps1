cd C:\swarn
.\Get_database_headers_v2.ps1 -folder \\an3prodsql01b\Backups\AN3PRODSQL01\AnnuityTransactions -backupext trn -tool RGT -drservername LAAN4DRXSQL01

cd C:\swarn
.\Get_database_headers_v2.ps1 -folder \\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\AnnuityTransactions -backupext bak -tool RGT -drservername LAAN4DRXSQL01

cd C:\swarn
.\Get_database_headers_v2.ps1 -folder \\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\AnnuityTransactions -backupext dmp -tool RGT -drservername LAAN4DRXSQL01