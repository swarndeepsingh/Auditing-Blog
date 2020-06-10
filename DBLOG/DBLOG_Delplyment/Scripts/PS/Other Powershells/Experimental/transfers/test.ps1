sqlbackupc.exe -SQL "RESTORE DATABASE [AnnuityTransactions] FROM DISK='\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\AnnuityTransactions\AN3PRODSQL01_RedGate_AnnuityTransactions_Full_20170513_2556.dmp' WITH PASSWORD = 'N0tBl4nk', NORECOVERY, MOVE DATAFILES TO 'U:\Database\DataFilesAnnuityTransactions\', MOVE LOGFILES TO 'W:\Database\LogFilesAnnuityTransactions\'" -I LAAN4DRXSQL01 -E -debug
SqlBackupC.exe -E  -SQL                  "RESTORE DATABASE [annuitytransactions] FROM DISK='\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\AnnuityTransactions\AN3PRODSQL01_RedGate_AnnuityTransactions_Full_20170513_2556.dmp' WITH PASSWORD = 'N0tBl4nk', NORECOVERY, MOVE 'AnnuityTransactions' TO 'U:\Database\DataFiles\annuitytransactions_sw.mdf', MOVE 'AnnuityTransaction_Index_1' TO 'U:\Database\DataFiles\annuitytransactions_sw_1.ndf', MOVE 'AnnuityTransactions_log' TO 'W:\Database\LogFiles\annuitytransactions_sw_2.ldf'" 




sc  sdset SQLBackupAgent

sc  sdshow SQLBackupAgent


sc  sdshow MSSQL$LAAN4DRXSQL01



sc sdset MSSQLSERVER D:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA) (A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY) (A;;CCLCSWLOCRRC;;;IU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;AU) S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;WD)

sc sdset SQLBackupAgent D:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA) (A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY) (A;;CCLCSWLOCRRC;;;IU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;AU) S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;WD)